import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/daily_reward.dart';
import '../../../domain/entities/game.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/daily_reward_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/dialogs/daily_reward_dialog.dart';
import '../../widgets/home/sign_in_prompt_card.dart';
import '../achievements/achievements_screen.dart';
import '../game/game_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../levels/level_select_screen.dart';
import '../multiplayer/multiplayer_lobby_screen.dart';
import '../online/online_lobby_screen.dart';
import '../quests/daily_quests_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import '../stats/statistics_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check for daily reward on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyReward();
      _syncPendingScores();
      // Schedules the daily reminder now, so its text follows the language
      // and sign-in state without the settings screen being opened.
      ref.read(notificationSettingsProvider);
    });
  }

  /// Sync any pending leaderboard scores in the background
  Future<void> _syncPendingScores() async {
    final leaderboardNotifier = ref.read(leaderboardProvider.notifier);
    await leaderboardNotifier.waitForLoad();

    // Sync in background - don't block UI
    leaderboardNotifier.syncPending();
  }

  Future<void> _checkDailyReward() async {
    final rewardNotifier = ref.read(dailyRewardProvider.notifier);

    // Wait for progress to be loaded from storage
    await rewardNotifier.waitForLoad();

    // Check if reward can be claimed after loading
    if (!mounted) return;
    if (rewardNotifier.canClaim) {
      showDialog(
        context: context,
        builder: (context) => const DailyRewardDialog(),
      ).then((reward) {
        if (reward != null && mounted) {
          final message = _buildRewardMessage(
            AppLocalizations.of(context)!,
            reward,
          );
          if (message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.successStrong,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final musicEnabled = settings.musicEnabled;

    // White status bar icons on the teal gradient
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // White text needs 4.5:1 on every part of the gradient;
              // primaryLight gives only 3.74:1.
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top bar - wallet and music toggle. Outside the scroll view,
                // so scrolled content does not pass under it.
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wallet display
                      _WalletButton(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ShopScreen(),
                          ),
                        ),
                      ),
                      // Music toggle; VoiceOver reads the on/off state too
                      Semantics(
                        toggled: musicEnabled,
                        child: IconButton(
                          tooltip: AppLocalizations.of(context)!.music,
                          onPressed: () {
                            ref.read(settingsProvider.notifier).toggleMusic();
                          },
                          icon: Icon(
                            musicEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main content with scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        // Logo / Title
                        const Icon(
                          Icons.psychology,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.appTitle,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.appSubtitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textLightSecondary),
                        ),
                        const SizedBox(height: 32),

                        // Only for players who have not signed in
                        const SignInPromptCard(),

                        // Play Button - Classic Mode
                        _MenuButton(
                          icon: Icons.play_arrow_rounded,
                          label: l10n.classicMode,
                          sublabel: l10n.classicModeDesc,
                          onTap: () => _startGame(context, GameMode.classic),
                        ),
                        const SizedBox(height: 12),

                        // Timed Mode Button
                        _MenuButton(
                          icon: Icons.timer,
                          label: l10n.timedMode,
                          sublabel: l10n.timedModeDesc,
                          onTap: () => _startGame(context, GameMode.timed),
                        ),
                        const SizedBox(height: 12),

                        // Online Multiplayer Mode Button
                        _MenuButton(
                          icon: Icons.public,
                          label: l10n.onlineMultiplayer,
                          sublabel: l10n.onlineMultiplayerDesc,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const OnlineLobbyScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Local Multiplayer Mode Button
                        _MenuButton(
                          icon: Icons.people,
                          label: l10n.localMultiplayer,
                          sublabel: l10n.localMultiplayerDesc,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MultiplayerLobbyScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Level Selection
                        _MenuButton(
                          icon: Icons.grid_view_rounded,
                          label: l10n.selectLevel,
                          sublabel: l10n.selectLevelDesc,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LevelSelectScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Settings Button
                        _MenuButton(
                          icon: Icons.settings,
                          label: l10n.settings,
                          sublabel: l10n.settingsDesc,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quick access row for gamification features
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _QuickAccessButton(
                              icon: Icons.insights_rounded,
                              label: l10n.statistics,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const StatisticsScreen(),
                                ),
                              ),
                            ),
                            _QuickAccessButton(
                              icon: Icons.emoji_events_rounded,
                              label: l10n.achievements,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AchievementsScreen(),
                                ),
                              ),
                            ),
                            _QuickAccessButton(
                              icon: Icons.today_rounded,
                              label: l10n.dailyQuests,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DailyQuestsScreen(),
                                ),
                              ),
                            ),
                            _QuickAccessButton(
                              icon: Icons.leaderboard_rounded,
                              label: l10n.leaderboard,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LeaderboardScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, GameMode mode) {
    ref
        .read(gameProvider.notifier)
        .startGame(
          level: 5, // Default 4x4
          mode: mode,
        );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          level: 5,
          mode: mode == GameMode.timed ? 'timed' : 'classic',
        ),
      ),
    );
  }

  String _buildRewardMessage(AppLocalizations l10n, DailyReward reward) {
    final parts = [
      if (reward.coins > 0) l10n.rewardCoins(reward.coins),
      if (reward.gems > 0) l10n.rewardGems(reward.gems),
      if (reward.powerUpId != null) l10n.rewardPowerUp,
    ];
    return parts.isEmpty ? '' : l10n.rewardClaimed(parts.join(', '));
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLightSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textLightSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletButton extends ConsumerWidget {
  final VoidCallback onTap;

  const _WalletButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              _formatAmount(wallet.coins),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.diamond_rounded,
              color: Colors.purpleAccent,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              wallet.gems.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}
