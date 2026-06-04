import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/theme_service.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '🎨 Choose your theme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a theme that matches your mood',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _themeCard(AppThemeType.light, theme)),
              const SizedBox(width: 12),
              Expanded(child: _themeCard(AppThemeType.dark, theme)),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your theme is saved and syncs across devices.',
                      style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeCard(AppThemeType type, ThemeData theme) {
    final info = AppTheme.themeInfo[type]!;
    final isSelected = _themeService.currentTheme == type;
    final isDark = type == AppThemeType.dark;
    final cardBg = isDark ? AppTheme.darkBackground : AppTheme.softBackground;
    final cardSurface = isDark ? AppTheme.darkCard : Colors.white;
    final headerBg = isDark ? AppTheme.darkAppBar : AppTheme.deepBlue;

    return GestureDetector(
      onTap: () async {
        await _themeService.setTheme(type);
        setState(() {});
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${info['emoji']} ${info['name']} theme applied'),
            backgroundColor: AppTheme.primaryOrange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryOrange.withAlpha(80)
                  : Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(height: 28, color: headerBg),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 8, backgroundColor: AppTheme.primaryOrange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 4,
                              color: isDark ? Colors.white24 : Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(info['emoji'], style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              info['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          info['description'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}