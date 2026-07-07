import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../../services/destination_service.dart';
import '../../theme/app_theme.dart';
import 'admin_destination_form.dart';

/// Warm Desert style — Destinations management tab.
class AdminDestinationsTab extends StatelessWidget {
  const AdminDestinationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DestinationService();

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: Column(
        children: [
          // ── Warm header ──────────────────────────────
          _WarmHeader(
            title: 'Destinations',
            subtitle: 'Manage all tourist destinations',
            action: FilledButton.icon(
              onPressed: () => _openForm(context, null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add New'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // ── List ─────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Destination>>(
              stream: service.streamAllDestinations(),
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
                final destinations = snap.data ?? [];
                if (destinations.isEmpty) {
                  return _WarmEmptyState(
                    icon: Icons.place_outlined,
                    message: 'No destinations yet',
                    subtitle: 'Add your first destination to get started.',
                    onAction: () => _openForm(context, null),
                    actionLabel: 'Add Destination',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: destinations.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _DestinationCard(
                    destination: destinations[i],
                    onEdit: () =>
                        _openForm(context, destinations[i]),
                    onDelete: () => _confirmDelete(
                        context, destinations[i], service),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, Destination? existing) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AdminDestinationForm(existing: existing)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Destination dest,
    DestinationService service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Destination'),
        content: Text(
            'Are you sure you want to permanently delete "${dest.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await service.deleteDestination(dest.id);
        if (context.mounted) {
          _showSnack(context, '"${dest.name}" deleted.',
              AppTheme.oasisGreen);
        }
      } catch (e) {
        if (context.mounted) {
          _showSnack(context, 'Error: $e', Colors.red);
        }
      }
    }
  }

  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ── Destination card ──────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.destination,
    required this.onEdit,
    required this.onDelete,
  });

  final Destination destination;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageUrl = destination.imageURLs.isNotEmpty
        ? destination.imageURLs.first
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(destination.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.deepBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        color: AppTheme.goldAccent, size: 14),
                    const SizedBox(width: 3),
                    Text(destination.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepBlue)),
                    const SizedBox(width: 6),
                    Text('(${destination.reviewsCount} reviews)',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.lightTextSecondary)),
                  ]),
                  const SizedBox(height: 5),
                  if (destination.tags.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.sandBeige,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(destination.tags,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.earthBrown),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionCircle(
                  icon: Icons.edit_rounded,
                  color: AppTheme.deepBlue,
                  onTap: onEdit,
                  tooltip: 'Edit',
                ),
                const SizedBox(height: 6),
                _ActionCircle(
                  icon: Icons.delete_rounded,
                  color: Colors.red,
                  onTap: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppTheme.sandBeige,
        child: const Center(
            child: Icon(Icons.image_outlined,
                color: AppTheme.earthBrown, size: 32)),
      );
}

// ── Shared warm UI components ─────────────────────────────────────────────────

/// Orange-accented page header used in every admin tab.
class _WarmHeader extends StatelessWidget {
  const _WarmHeader(
      {required this.title, required this.subtitle, this.action});

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 500;
    return Container(
      padding: EdgeInsets.fromLTRB(16, isNarrow ? 14 : 28, 16, isNarrow ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: AppTheme.lightBorder, width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: isNarrow && action != null
          // ── Mobile: stack vertically ─────────────────
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.deepBlue)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.lightTextSecondary)),
                const SizedBox(height: 10),
                action!,
              ],
            )
          // ── Wide: side by side ───────────────────────
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.deepBlue)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.lightTextSecondary)),
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
    );
  }
}

class _WarmEmptyState extends StatelessWidget {
  const _WarmEmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  final IconData icon;
  final String message;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.sandBeige,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppTheme.earthBrown),
          ),
          const SizedBox(height: 20),
          Text(message,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepBlue)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.lightTextSecondary)),
          if (onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel ?? 'Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
