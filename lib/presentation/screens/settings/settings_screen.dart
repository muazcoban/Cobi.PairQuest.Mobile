import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/card_shuffle.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../themes/theme_select_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSectionHeader(l10n.language),
          _buildLanguageTile(
            context: context,
            ref: ref,
            title: l10n.turkish,
            subtitle: 'Türkçe',
            locale: const Locale('tr'),
            currentLocale: settings.locale,
          ),
          _buildLanguageTile(
            context: context,
            ref: ref,
            title: l10n.english,
            subtitle: 'English',
            locale: const Locale('en'),
            currentLocale: settings.locale,
          ),
          const SizedBox(height: 24),

          // Theme Section
          _buildSectionHeader(l10n.theme),
          _buildThemeTile(
            context: context,
            ref: ref,
            title: l10n.lightMode,
            icon: Icons.light_mode,
            themeMode: ThemeMode.light,
            currentTheme: settings.themeMode,
          ),
          _buildThemeTile(
            context: context,
            ref: ref,
            title: l10n.darkMode,
            icon: Icons.dark_mode,
            themeMode: ThemeMode.dark,
            currentTheme: settings.themeMode,
          ),
          _buildThemeTile(
            context: context,
            ref: ref,
            title: l10n.systemDefault,
            icon: Icons.settings_suggest,
            themeMode: ThemeMode.system,
            currentTheme: settings.themeMode,
          ),
          const SizedBox(height: 24),

          // Card Theme Section
          _buildSectionHeader(l10n.cardTheme),
          _buildCardThemeTile(context, ref, settings.cardTheme, l10n),
          const SizedBox(height: 24),

          // Sound Section
          _buildSectionHeader(l10n.sound),
          SwitchListTile(
            title: Text(l10n.sound),
            secondary: const Icon(Icons.volume_up),
            value: settings.soundEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleSound();
            },
          ),
          SwitchListTile(
            title: Text(l10n.vibration),
            secondary: const Icon(Icons.vibration),
            value: settings.vibrationEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleVibration();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required Locale locale,
    required Locale currentLocale,
  }) {
    final isSelected = locale.languageCode == currentLocale.languageCode;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setLocale(locale);
      },
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required ThemeMode themeMode,
    required ThemeMode currentTheme,
  }) {
    final isSelected = themeMode == currentTheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setThemeMode(themeMode);
      },
    );
  }

  Widget _buildCardThemeTile(
    BuildContext context,
    WidgetRef ref,
    String currentTheme,
    AppLocalizations l10n,
  ) {
    final themeNames = {
      'animals': l10n.animals,
      'fruits': l10n.fruits,
      'flags': l10n.flags,
      'sports': l10n.sports,
      'nature': l10n.nature,
      'travel': l10n.travel,
      'food': l10n.food,
      'objects': l10n.objects,
    };
    final emojis = CardShuffle.themeImages[currentTheme]?.take(4).join(' ') ?? '';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(emojis.split(' ').first, style: const TextStyle(fontSize: 20)),
        ),
      ),
      title: Text(themeNames[currentTheme] ?? currentTheme),
      subtitle: Text(emojis),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ThemeSelectScreen()),
        );
      },
    );
  }
}
