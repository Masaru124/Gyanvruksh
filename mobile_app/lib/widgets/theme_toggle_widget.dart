import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final IconData? lightIcon;
  final IconData? darkIcon;
  final IconData? systemIcon;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = true,
    this.lightIcon,
    this.darkIcon,
    this.systemIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return PopupMenuButton<ThemeMode>(
          icon: Icon(_getCurrentIcon(themeProvider.themeMode)),
          tooltip: 'Change theme',
          onSelected: (ThemeMode mode) {
            themeProvider.setThemeMode(mode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(
                    lightIcon ?? Icons.light_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (showLabel) const Text('Light'),
                  if (themeProvider.themeMode == ThemeMode.light)
                    const Spacer(),
                  if (themeProvider.themeMode == ThemeMode.light)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(
                    darkIcon ?? Icons.dark_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (showLabel) const Text('Dark'),
                  if (themeProvider.themeMode == ThemeMode.dark)
                    const Spacer(),
                  if (themeProvider.themeMode == ThemeMode.dark)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(
                    systemIcon ?? Icons.auto_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (showLabel) const Text('System'),
                  if (themeProvider.themeMode == ThemeMode.system)
                    const Spacer(),
                  if (themeProvider.themeMode == ThemeMode.system)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getCurrentIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return lightIcon ?? Icons.light_mode;
      case ThemeMode.dark:
        return darkIcon ?? Icons.dark_mode;
      case ThemeMode.system:
        return systemIcon ?? Icons.auto_mode;
    }
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(_getCurrentIcon(themeProvider.themeMode)),
          tooltip: 'Toggle theme',
          onPressed: () {
            themeProvider.toggleTheme();
          },
        );
      },
    );
  }

  IconData _getCurrentIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_mode;
    }
  }
}
