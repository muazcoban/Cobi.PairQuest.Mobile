import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/matchmaking.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matchmaking_provider.dart';
import '../../providers/online_profile_provider.dart';
import 'online_game_screen.dart';

/// Matchmaking screen with search animation
class MatchmakingScreen extends ConsumerStatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  ConsumerState<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends ConsumerState<MatchmakingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSearching();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startSearching() {
    final authState = ref.read(authProvider);
    final user = authState.user;
    final profile = ref.read(onlineProfileNotifierProvider).valueOrNull;
    final mode = ref.read(selectedMatchmakingModeProvider);

    if (user != null && profile != null) {
      ref.read(matchmakingProvider.notifier).startSearch(
            oddserId: user.uid,
            displayName: authState.displayName,
            photoUrl: user.photoURL,
            rating: profile.rating,
            mode: mode,
          );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matchmakingStatus = ref.watch(matchmakingProvider);

    // Listen for match found
    ref.listen<MatchmakingSearchStatus>(matchmakingProvider, (prev, next) {
      if (next.state == MatchmakingUIState.matched && next.gameId != null) {
        _onMatchFound(next.gameId!);
      } else if (next.state == MatchmakingUIState.timeout) {
        _onTimeout(l10n);
      } else if (next.state == MatchmakingUIState.error) {
        _onError(l10n, next.errorMessage ?? 'Unknown error');
      }
    });

    return WillPopScope(
      onWillPop: () async {
        await ref.read(matchmakingProvider.notifier).cancelSearch();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top bar with cancel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await ref.read(matchmakingProvider.notifier).cancelSearch();
                        if (mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary(context),
                    ),
                    Text(
                      _getModeTitle(l10n, ref.watch(selectedMatchmakingModeProvider)),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance
                  ],
                ),
                const Spacer(),

                // Search animation
                _buildSearchAnimation(matchmakingStatus),
                const SizedBox(height: 40),

                // Status text
                _buildStatusText(l10n, matchmakingStatus),
                const SizedBox(height: 16),

                // Timer and rating info
                _buildSearchInfo(l10n, matchmakingStatus),
                const Spacer(),

                // Cancel button
                _buildCancelButton(l10n),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getModeTitle(AppLocalizations l10n, MatchmakingMode mode) {
    switch (mode) {
      case MatchmakingMode.ranked:
        return l10n.rankedPlay;
      case MatchmakingMode.casual:
        return l10n.quickPlay;
      default:
        return l10n.findingMatch;
    }
  }

  Widget _buildSearchAnimation(MatchmakingSearchStatus status) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 3,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        AppColors.primary.withOpacity(0),
                        AppColors.primary,
                        AppColors.primary.withOpacity(0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // Pulsing inner circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),

          // Center icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(AppLocalizations l10n, MatchmakingSearchStatus status) {
    String text;
    switch (status.state) {
      case MatchmakingUIState.searching:
        text = l10n.searchingForOpponent;
        break;
      case MatchmakingUIState.matched:
        text = l10n.matchFound;
        break;
      case MatchmakingUIState.timeout:
        text = l10n.searchTimeout;
        break;
      case MatchmakingUIState.error:
        text = l10n.errorOccurred;
        break;
      default:
        text = l10n.preparingMatch;
    }

    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        if (status.state == MatchmakingUIState.searching) ...[
          const SizedBox(height: 8),
          _buildSearchDots(),
        ],
      ],
    );
  }

  Widget _buildSearchDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 200)),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.3 + (value * 0.7)),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSearchInfo(AppLocalizations l10n, MatchmakingSearchStatus status) {
    if (status.state != MatchmakingUIState.searching) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Time
          Column(
            children: [
              Icon(
                Icons.timer,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(status.searchTimeSeconds),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                l10n.searchTime,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.cardBorder(context),
          ),
          // Rating range
          Column(
            children: [
              Icon(
                Icons.leaderboard,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                '±${status.ratingRadius}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                l10n.ratingRange,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildCancelButton(AppLocalizations l10n) {
    return TextButton(
      onPressed: () async {
        await ref.read(matchmakingProvider.notifier).cancelSearch();
        if (mounted) Navigator.of(context).pop();
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(
        l10n.cancel,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _onMatchFound(String gameId) {
    // Short delay to show "Match Found!" message
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnlineGameScreen(gameId: gameId),
          ),
        );
      }
    });
  }

  void _onTimeout(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.searchTimeout),
        content: Text(l10n.noOpponentFound),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(l10n.ok),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startSearching();
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _onError(AppLocalizations l10n, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.errorOccurred}: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
