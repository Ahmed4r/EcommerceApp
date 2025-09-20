import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/theme/theme_cubit.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final double? iconSize;

  const ThemeToggleWidget({super.key, this.showLabel = true, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeDark;

        if (showLabel) {
          return ListTile(
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: iconSize ?? 24,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              'Dark Mode',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Switch.adaptive(
              value: isDarkMode,
              onChanged: (value) {
                context.read<ThemeCubit>().toggleTheme();
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            onTap: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          );
        } else {
          return IconButton(
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: iconSize ?? 24,
              color: Theme.of(context).iconTheme.color,
            ),
            tooltip: isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          );
        }
      },
    );
  }
}

class ThemeToggleSwitch extends StatelessWidget {
  final String? label;
  final double? switchScale;

  const ThemeToggleSwitch({super.key, this.label, this.switchScale});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeDark;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.light_mode,
              size: 20,
              color: isDarkMode
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: switchScale ?? 1.0,
              child: Switch.adaptive(
                value: isDarkMode,
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.dark_mode,
              size: 20,
              color: isDarkMode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            if (label != null) ...[
              const SizedBox(width: 12),
              Text(label!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        );
      },
    );
  }
}

class ThemeToggleCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;

  const ThemeToggleCard({super.key, this.title, this.subtitle, this.padding});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeDark;

        return Card(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? 'Theme',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: Theme.of(
                //       context,
                //     ).colorScheme.primary.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(
                //       color: Theme.of(
                //         context,
                //       ).colorScheme.primary.withOpacity(0.2),
                //     ),
                //   ),
                //   child: Text(
                //     isDarkMode
                //         ? 'Dark mode is active - easier on the eyes in low light'
                //         : 'Light mode is active - great for daytime use',
                //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //       color: Theme.of(context).colorScheme.primary,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
