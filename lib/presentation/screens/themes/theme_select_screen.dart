import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/card_shuffle.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/settings_provider.dart';

/// Theme selection screen with preview
class ThemeSelectScreen extends ConsumerWidget {
  const ThemeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final currentTheme = settings.cardTheme;

    final themes = [
      _ThemeData('animals', l10n.animals, Icons.pets_rounded),
      _ThemeData('fruits', l10n.fruits, Icons.apple),
      _ThemeData('flags', l10n.flags, Icons.flag_rounded),
      _ThemeData('sports', l10n.sports, Icons.sports_soccer_rounded),
      _ThemeData('nature', l10n.nature, Icons.eco_rounded),
      _ThemeData('travel', l10n.travel, Icons.directions_car_rounded),
      _ThemeData('food', l10n.food, Icons.restaurant_rounded),
      _ThemeData('objects', l10n.objects, Icons.devices_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.cardTheme),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final theme = themes[index];
            final isSelected = theme.id == currentTheme;
            final emojis = CardShuffle.themeImages[theme.id] ?? [];

            return _ThemeCard(
              theme: theme,
              emojis: emojis.take(6).toList(),
              isSelected: isSelected,
              onTap: () {
                ref.read(settingsProvider.notifier).setCardTheme(theme.id);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ThemeData {
  final String id;
  final String name;
  final IconData icon;

  const _ThemeData(this.id, this.name, this.icon);
}

class _ThemeCard extends StatelessWidget {
  final _ThemeData theme;
  final List<String> emojis;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.emojis,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Emoji preview grid
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: emojis.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              emojis[index],
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Theme name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(17),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        theme.icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        theme.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Checkmark for selected
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
