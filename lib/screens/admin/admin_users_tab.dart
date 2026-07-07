import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

/// Warm Desert style — Users management tab.
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _adminService = AdminService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Users',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepBlue)),
                const Text('All registered users',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.lightTextSecondary)),
                const SizedBox(height: 14),
                // Search bar
                TextField(
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email…',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.primaryOrange, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: AppTheme.softBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.lightBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.primaryOrange, width: 2),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                size: 18),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _adminService.streamAllUsersByName(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryOrange));
                }
                if (snap.hasError) {
                  return Center(
                      child: Text('Error: ${snap.error}',
                          style: const TextStyle(color: Colors.red)));
                }
                final users = (snap.data ?? []).where((u) {
                  if (_searchQuery.isEmpty) return true;
                  final name =
                      (u['name'] ?? '').toString().toLowerCase();
                  final email =
                      (u['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: AppTheme.sandBeige,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_outline_rounded,
                              size: 44, color: AppTheme.earthBrown),
                        ),
                        const SizedBox(height: 16),
                        const Text('No users found',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepBlue)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: users.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _UserCard(
                    user: users[i],
                    onDelete: () =>
                        _deleteUser(ctx, users[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(
      BuildContext ctx, Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove User Document'),
        content: Text(
            'Remove Firestore document for "${user['name'] ?? user['email'] ?? user['id']}"?\n\nNote: This does NOT delete their Firebase Auth account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Remove',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      try {
        await _adminService
            .deleteUserDocument(user['id'] as String);
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('User document removed.'),
            backgroundColor: AppTheme.oasisGreen,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } catch (e) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onDelete});

  final Map<String, dynamic> user;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = user['name'] as String? ?? 'No name';
    final email = user['email'] as String? ?? '';
    final role = user['role'] as String? ?? 'user';
    final uid = user['id'] as String? ?? '';
    final isAdmin = role == 'admin';

    // Avatar initials
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdmin
              ? AppTheme.goldAccent.withAlpha(120)
              : AppTheme.lightBorder,
          width: isAdmin ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAdmin
                  ? [
                      AppTheme.primaryOrange,
                      const Color(0xFF8B3A1A),
                    ]
                  : [AppTheme.deepBlue, const Color(0xFF2C4A6E)],
            ),
            shape: BoxShape.circle,
          ),
          child: Text(
            initials,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepBlue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppTheme.primaryOrange,
                    Color(0xFF8B3A1A),
                  ]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded,
                        color: Colors.white, size: 10),
                    SizedBox(width: 3),
                    Text('ADMIN',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8)),
                  ],
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty)
              Text(email,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            Text(
                'UID: ${uid.length > 12 ? '${uid.substring(0, 12)}…' : uid}',
                style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.lightTextSecondary)),
          ],
        ),
        trailing: GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_remove_outlined,
                color: Colors.red, size: 18),
          ),
        ),
      ),
    );
  }
}
