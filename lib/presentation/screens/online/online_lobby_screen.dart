import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/matchmaking.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friends_provider.dart';
import '../../providers/matchmaking_provider.dart';
import '../../providers/online_profile_provider.dart';
import '../../widgets/common/wallet_display.dart';
import '../../widgets/dialogs/game_invitation_dialog.dart';
import 'friends_screen.dart';
import 'matchmaking_screen.dart';
import 'online_leaderboard_screen.dart';

/// Online multiplayer lobby screen
class OnlineLobbyScreen extends ConsumerStatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  ConsumerState<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends ConsumerState<OnlineLobbyScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfile();
    });
  }

  Future<void> _initializeProfile() async {
    if (!mounted || _initialized) return;
    _initialized = true;

    final authState = ref.read(authProvider);
    final user = authState.user;
    // Only initialize for non-anonymous users
    if (user != null && !authState.isAnonymous) {
      await ref.read(onlineProfileNotifierProvider.notifier).initializeProfile(
            oddserId: user.uid,
            displayName: authState.displayName,
            photoUrl: user.photoURL,
            email: user.email,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAnonymous = authState.isAnonymous;
    final profileAsync = ref.watch(onlineProfileNotifierProvider);

    // Online features require Google login (not anonymous)
    final needsLogin = user == null || isAnonymous;

    final scaffold = Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.onlineMultiplayer),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          WalletDisplay(),
          SizedBox(width: 8),
        ],
      ),
      body: needsLogin
          ? _buildLoginRequired(l10n)
          : profileAsync.when(
              data: (profile) => _buildLobbyContent(l10n, profile),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildError(l10n, e.toString()),
            ),
    );

    // Wrap with invitation listener if user is logged in (not anonymous)
    if (user != null && !isAnonymous) {
      return InvitationListener(
        userId: user.uid,
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildLoginRequired(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 80,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.loginRequired,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.loginToPlayOnline,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                // Sign in with Google
                final success = await ref.read(authProvider.notifier).signInWithGoogle();
                if (success && mounted) {
                  // Re-initialize profile after login
                  _initialized = false;
                  _initializeProfile();
                }
              },
              icon: const Icon(Icons.login),
              label: Text(l10n.signInWithGoogle),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initializeProfile,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLobbyContent(AppLocalizations l10n, profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile card
          if (profile != null) _buildProfileCard(l10n, profile),
          const SizedBox(height: 24),

          // Quick Play button
          _buildQuickPlayButton(l10n),
          const SizedBox(height: 16),

          // Ranked Play button
          _buildRankedPlayButton(l10n),
          const SizedBox(height: 32),

          // Mode selection section
          _buildModeSection(l10n),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AppLocalizations l10n, profile) {
    final tierName = ref.watch(userTierNameProvider(profile.rating));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage:
                profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
            child: profile.photoUrl == null
                ? Text(
                    profile.displayName.isNotEmpty
                        ? profile.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber.shade300,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tierName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${profile.rating}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats section - Ranked and Casual
                _buildStatsSection(l10n, profile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations l10n, profile) {
    return Column(
      children: [
        // Ranked stats row
        Row(
          children: [
            Icon(Icons.emoji_events, size: 14, color: Colors.orange.shade300),
            const SizedBox(width: 4),
            Text(
              l10n.ranked,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${profile.rankedWins}W',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade300,
              ),
            ),
            Text(
              ' / ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Text(
              '${profile.rankedLosses}L',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade300,
              ),
            ),
            if (profile.rankedGames > 0) ...[
              const SizedBox(width: 6),
              Text(
                '(${profile.rankedWinRate.toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber.shade300,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        // Casual stats row
        Row(
          children: [
            Icon(Icons.flash_on, size: 14, color: Colors.green.shade300),
            const SizedBox(width: 4),
            Text(
              l10n.casual,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${profile.casualWins}W',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade300,
              ),
            ),
            Text(
              ' / ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Text(
              '${profile.casualLosses}L',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade300,
              ),
            ),
            if (profile.casualGames > 0) ...[
              const SizedBox(width: 6),
              Text(
                '(${profile.casualWinRate.toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber.shade300,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPlayButton(AppLocalizations l10n) {
    return _buildPlayButton(
      icon: Icons.flash_on,
      title: l10n.quickPlay,
      subtitle: l10n.quickPlayDesc,
      color: Colors.green,
      onTap: () => _startMatchmaking(ranked: false),
    );
  }

  Widget _buildRankedPlayButton(AppLocalizations l10n) {
    return _buildPlayButton(
      icon: Icons.emoji_events,
      title: l10n.rankedPlay,
      subtitle: l10n.rankedPlayDesc,
      color: Colors.orange,
      onTap: () => _startMatchmaking(ranked: true),
    );
  }

  Widget _buildPlayButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.cardBackground(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSection(AppLocalizations l10n) {
    final userId = ref.watch(authProvider).user?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.moreOptions,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                icon: Icons.people,
                title: l10n.friends,
                color: Colors.blue,
                badge: userId != null
                    ? ref.watch(pendingRequestsCountProvider(userId))
                    : 0,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FriendsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                icon: Icons.leaderboard,
                title: l10n.leaderboard,
                color: Colors.purple,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OnlineLeaderboardScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Material(
      color: AppColors.cardBackground(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cardBorder(context),
            ),
          ),
          child: Column(
            children: [
              badge > 0
                  ? Badge(
                      label: Text('$badge'),
                      child: Icon(icon, color: color, size: 32),
                    )
                  : Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startMatchmaking({required bool ranked}) {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    ref.read(selectedMatchmakingModeProvider.notifier).state =
        ranked ? MatchmakingMode.ranked : MatchmakingMode.casual;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MatchmakingScreen(),
      ),
    );
  }
}
