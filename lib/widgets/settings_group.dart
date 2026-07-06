import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';

/// An iOS-style large-title app bar: plain scaffold-background bar (no
/// colored fill), small back chevron, bold large navy/light title. Used by
/// the Account feature-area screens instead of the app-wide navy [AppBar]
/// so they read as native "Settings.app" grouped-list screens.
class LargeTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const LargeTitleBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.deepBlue;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: titleColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: actions,
    );
  }
}

/// Small-caps gray section label above a [SettingsGroupCard], e.g.
/// "PREFERENCES" / "ACCOUNT" — matches iOS Settings.app section headers.
class SettingsSectionLabel extends StatelessWidget {
  final String text;

  const SettingsSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding + AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

/// A rounded, inset "grouped list" container — the classic iOS Settings.app
/// card that holds a set of rows (typically [SettingsRow]s) separated by
/// thin dividers, sharing a single rounded background.
class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroupCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final dividerColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Divider(height: 1, thickness: 1, color: dividerColor),
        ));
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

/// One row inside a [SettingsGroupCard]: a small circular icon badge, a
/// label (+ optional subtitle), and a trailing control — a chevron for
/// navigation rows, or any custom widget (e.g. a `Switch`) via [trailing].
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppTheme.primaryOrange,
    this.labelColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chevronColor = theme.textTheme.bodySmall?.color;

    final trailingWidget = trailing ??
        (showChevron
            ? Icon(Icons.chevron_right_rounded, color: chevronColor, size: 22)
            : null);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: 8),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
  }
}
