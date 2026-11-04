import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_links.dart';
import '../../../core/moderation/name_filter.dart';
import '../../../core/utils/card_shuffle.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/auth_screen.dart';
import '../themes/theme_select_screen.dart';
import 'blocked_players_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: AppTheme.onPrimaryTitleStyle,
        iconTheme: AppTheme.onPrimaryIconTheme,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader(context, l10n.account),
          _buildAccountTile(context, ref, authState, l10n),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => AppLinks.open(AppLinks.privacyPolicy),
          ),
          // App Review 1.2: published contact information
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(l10n.contactUs),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => AppLinks.open(AppLinks.contactEmail),
          ),
          if (authState.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(l10n.blockedPlayers),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedPlayersScreen()),
              ),
            ),
          if (authState.isAuthenticated)
            ListTile(
              leading: Icon(
                Icons.delete_forever_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.deleteAccount,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _confirmDeleteAccount(context, ref, authState, l10n),
            ),
          const SizedBox(height: 24),

          // Player Name Section
          _buildSectionHeader(context, l10n.playerName),
          _buildPlayerNameTile(context, ref, settings.playerName, l10n),
          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(context, l10n.language),
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
          _buildSectionHeader(context, l10n.theme),
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
          _buildSectionHeader(context, l10n.cardTheme),
          _buildCardThemeTile(context, ref, settings.cardTheme, l10n),
          const SizedBox(height: 24),

          // Sound Section
          _buildSectionHeader(context, l10n.sound),
          SwitchListTile(
            title: Text(l10n.music),
            subtitle: Text(l10n.musicDesc),
            secondary: const Icon(Icons.music_note_rounded),
            value: settings.musicEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleMusic();
            },
          ),
          SwitchListTile(
            title: Text(l10n.soundEffects),
            subtitle: Text(l10n.soundEffectsDesc),
            secondary: const Icon(Icons.volume_up_rounded),
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
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, l10n.notifications),
          SwitchListTile(
            title: Text(l10n.dailyReminder),
            subtitle: Text(
              notificationSettings.dailyReminderEnabled
                  ? '${l10n.reminderTime}: ${notificationSettings.formattedReminderTime}'
                  : l10n.dailyReminderDesc,
            ),
            secondary: const Icon(Icons.notifications_active_rounded),
            value: notificationSettings.dailyReminderEnabled,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setDailyReminder(value);
            },
          ),
          if (notificationSettings.dailyReminderEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(l10n.reminderTime),
              subtitle: Text(notificationSettings.formattedReminderTime),
              trailing: const Icon(Icons.access_time_rounded),
              onTap: () => _showTimePicker(context, ref, notificationSettings),
            ),
          SwitchListTile(
            title: Text(l10n.achievementAlerts),
            subtitle: Text(l10n.achievementAlertsDesc),
            secondary: const Icon(Icons.emoji_events_rounded),
            value: notificationSettings.achievementNotifications,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setAchievementNotifications(value);
            },
          ),
          SwitchListTile(
            title: Text(l10n.questAlerts),
            subtitle: Text(l10n.questAlertsDesc),
            secondary: const Icon(Icons.task_alt_rounded),
            value: notificationSettings.questNotifications,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setQuestNotifications(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerNameTile(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.person_rounded,
          color: AppColors.primary,
        ),
      ),
      title: Text(currentName),
      subtitle: Text(l10n.tapToChange),
      trailing: const Icon(Icons.edit_rounded),
      onTap: () => _showPlayerNameDialog(context, ref, currentName, l10n),
    );
  }

  void _showPlayerNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: currentName);
    String? error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // The name is public on the global leaderboard (App Review 1.2).
          void save() {
            if (!NameFilter.isAllowed(controller.text)) {
              setState(() => error = l10n.nameNotAllowed);
              return;
            }
            ref.read(settingsProvider.notifier).setPlayerName(controller.text);
            Navigator.of(context).pop();
          }

          return AlertDialog(
            title: Text(l10n.playerName),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: l10n.enterYourName,
                errorText: error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => save(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      // VoiceOver lists headings in the rotor (HIG VoiceOver, Navigation).
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText(context),
          ),
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

  Widget _buildAccountTile(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    AppLocalizations l10n,
  ) {
    if (authState.isAuthenticated && !authState.isAnonymous) {
      // Signed in with Google
      return Column(
        children: [
          ListTile(
            leading: authState.photoUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(authState.photoUrl!),
                  )
                : CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
            title: Text(authState.displayName),
            // HIG Sign in with Apple: show which sign-in is in use. The
            // e-mail may be a private relay address, so it is not shown.
            subtitle: Text(authState.isAppleLinked
                ? l10n.signedInWithApple
                : authState.email ?? l10n.account),
            trailing: IconButton(
              tooltip: AppLocalizations.of(context)!.signOut,
              icon: const Icon(Icons.logout),
              onPressed: () => _showSignOutDialog(context, ref, l10n),
            ),
          ),
        ],
      );
    }

    // Not signed in or anonymous
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.person_outline, color: AppColors.primary),
      ),
      title: Text(authState.isAnonymous ? l10n.guest : l10n.signIn),
      subtitle: Text(l10n.linkAccountDesc),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AuthScreen(
              returnMessage: l10n.signInToSaveProgress,
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.continueQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text([
          l10n.deleteAccountConfirm,
          l10n.deleteAccountDetails,
          if (authState.isAppleLinked)
            l10n.deleteAccountReauthApple
          else if (authState.isGoogleLinked)
            l10n.deleteAccountReauth,
        ].join('\n\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          // Not in the destructive style: the user already chose to delete
          // (HIG, Alerts).
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    final result = await ref.read(authProvider.notifier).deleteAccount();
    navigator.pop();

    final message = switch (result) {
      AccountDeletionResult.deleted => l10n.accountDeleted,
      AccountDeletionResult.cancelled => null,
      AccountDeletionResult.wrongAccount => l10n.accountDeletionWrongAccount,
      AccountDeletionResult.failed => l10n.accountDeletionFailed,
    };
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
    );

    if (time != null) {
      ref.read(notificationSettingsProvider.notifier).setReminderTime(
            time.hour,
            time.minute,
          );
    }
  }
}
