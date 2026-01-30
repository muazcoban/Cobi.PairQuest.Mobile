import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/online_game.dart';
import '../../../domain/entities/online_player.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friends_provider.dart';
import '../../providers/online_game_provider.dart';
import '../../providers/online_profile_provider.dart';

/// Online multiplayer game screen
///
/// CRITICAL DEPENDENCY: [currentPlayerIdProvider] must be set BEFORE navigating
/// to this screen. Otherwise [myId] will be null and turn detection fails.
///
/// This provider is set in:
/// - [GameInvitationDialog._accept] - for invitation receiver
/// - [_InvitationWaitingDialog] in friends_screen.dart - for invitation sender
/// - [OnlineProfileNotifier.initializeProfile] - for matchmaking flow
class OnlineGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const OnlineGameScreen({super.key, required this.gameId});

  @override
  ConsumerState<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends ConsumerState<OnlineGameScreen>
    with TickerProviderStateMixin {
  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isProcessing = false;
  Timer? _turnTimer;
  int _turnTimeRemaining = 30;
  bool _ratingUpdated = false;

  @override
  void initState() {
    super.initState();
    _startTurnTimer();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  void _startTurnTimer() {
    _turnTimer?.cancel();
    _turnTimeRemaining = 30;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_turnTimeRemaining > 0) {
        setState(() => _turnTimeRemaining--);
      } else {
        // Turn timeout - auto-skip
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameAsync = ref.watch(onlineGameProvider(widget.gameId));
    final myId = ref.watch(currentPlayerIdProvider);

    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await _showLeaveConfirmation(l10n);
        return shouldLeave;
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: gameAsync.when(
            data: (game) {
              if (game == null) {
                return _buildGameNotFound(l10n);
              }
              return _buildGameContent(l10n, game, myId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildError(l10n, e.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildGameNotFound(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(l10n.gameNotFound),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('${l10n.errorOccurred}: $error'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(AppLocalizations l10n, OnlineGame game, String? myId) {
    // Check game status
    if (game.status == OnlineGameStatus.completed) {
      // Update stats when game is completed (only once, for all game modes)
      if (!_ratingUpdated && myId != null) {
        _ratingUpdated = true;
        _updateStatsAfterGame(game, myId);
      }
      return _buildGameOver(l10n, game, myId);
    }
    if (game.status == OnlineGameStatus.abandoned) {
      // Update stats when game is abandoned (only once, for all game modes)
      if (!_ratingUpdated && myId != null) {
        _ratingUpdated = true;
        _updateStatsAfterGame(game, myId);
      }
      return _buildGameAbandoned(l10n, game, myId);
    }

    final isMyTurn = game.isPlayerTurn(myId ?? '');
    final myPlayer = game.players.firstWhere(
      (p) => p.oddserId == myId,
      orElse: () => game.players.first,
    );
    final opponent = game.players.firstWhere(
      (p) => p.oddserId != myId,
      orElse: () => game.players.last,
    );

    // Debug: Log turn state
    debugPrint('🎮 Turn state: myId=$myId, currentPlayerIndex=${game.currentPlayerIndex}, '
        'player0=${game.players[0].oddserId}, player1=${game.players.length > 1 ? game.players[1].oddserId : "N/A"}, '
        'isMyTurn=$isMyTurn');

    return Column(
      children: [
        // Top bar - Opponent info
        _buildPlayerBar(opponent, isOpponent: true, isCurrentTurn: !isMyTurn),
        const SizedBox(height: 8),

        // Game info bar
        _buildGameInfoBar(l10n, game, isMyTurn),
        const SizedBox(height: 8),

        // Game board
        Expanded(
          child: _buildGameBoard(game, isMyTurn),
        ),

        // Bottom bar - My info
        const SizedBox(height: 8),
        _buildPlayerBar(myPlayer, isOpponent: false, isCurrentTurn: isMyTurn),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlayerBar(OnlinePlayer player, {
    required bool isOpponent,
    required bool isCurrentTurn,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? player.color.withOpacity(0.15)
            : AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentTurn ? player.color : AppColors.cardBorder(context),
          width: isCurrentTurn ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: player.color.withOpacity(0.2),
                backgroundImage: player.photoUrl != null
                    ? NetworkImage(player.photoUrl!)
                    : null,
                child: player.photoUrl == null
                    ? Text(
                        player.displayName.isNotEmpty
                            ? player.displayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: player.color,
                        ),
                      )
                    : null,
              ),
              // Connection indicator
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: player.isConnected ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Name and rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isCurrentTurn)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: player.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    Text(
                      isOpponent ? player.displayName : 'You',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${player.tierName} • ${player.rating}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: player.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${player.score}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: player.color,
                  ),
                ),
                Text(
                  '${player.matches} pairs',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoBar(AppLocalizations l10n, OnlineGame game, bool isMyTurn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Leave game button
          GestureDetector(
            onTap: () => _showLeaveConfirmation(l10n),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.exit_to_app,
                size: 18,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Turn indicator
          Expanded(
            child: Row(
              children: [
                Icon(
                  isMyTurn ? Icons.touch_app : Icons.hourglass_empty,
                  color: isMyTurn ? Colors.green : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isMyTurn ? l10n.yourTurn : l10n.opponentTurn,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isMyTurn ? Colors.green : Colors.orange,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Pairs remaining
          Row(
            children: [
              const Icon(Icons.grid_view, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${game.remainingPairs}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Turn timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _turnTimeRemaining < 10
                  ? Colors.red.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 14,
                  color: _turnTimeRemaining < 10 ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_turnTimeRemaining}s',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _turnTimeRemaining < 10 ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(OnlineGame game, bool isMyTurn) {
    final matchedPairIds = Set<String>.from(game.matchedPairIds);

    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: game.cols,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: game.totalCards,
        itemBuilder: (context, index) {
          final pairId = game.cardPairIds[index];
          final isMatched = matchedPairIds.contains(pairId);
          final isRevealed = _firstCardIndex == index ||
              _secondCardIndex == index ||
              isMatched;

          return GestureDetector(
            key: ValueKey('card_${game.id}_$index'),  // Performance: add key for efficient rebuilds
            onTap: isMyTurn && !_isProcessing && !isMatched && !isRevealed
                ? () => _onCardTap(index, game)
                : null,
            child: _buildCard(
              index: index,
              pairId: pairId,
              isRevealed: isRevealed,
              isMatched: isMatched,
              isEnabled: isMyTurn && !_isProcessing,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required int index,
    required String pairId,
    required bool isRevealed,
    required bool isMatched,
    required bool isEnabled,
  }) {
    // pairId is now an emoji (e.g., "🐶", "🐱")
    final isEmoji = pairId.isNotEmpty && !pairId.startsWith('pair_');
    final displayContent = isEmoji ? pairId : '${int.tryParse(pairId.replaceAll('pair_', '')) ?? 0 + 1}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isMatched
            ? Colors.green.withOpacity(0.3)
            : isRevealed
                ? AppColors.primary.withOpacity(0.8)
                : isEnabled
                    ? AppColors.cardBackground(context)
                    : AppColors.cardBackground(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched
              ? Colors.green
              : isRevealed
                  ? AppColors.primary
                  : AppColors.cardBorder(context),
          width: 2,
        ),
        boxShadow: isEnabled && !isMatched
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isRevealed || isMatched
            ? Text(
                displayContent,
                style: TextStyle(
                  fontSize: isEmoji ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: isMatched ? Colors.green : (isEmoji ? null : Colors.white),
                ),
              )
            : Icon(
                Icons.question_mark,
                color: AppColors.textSecondary(context),
                size: 24,
              ),
      ),
    );
  }

  Future<void> _onCardTap(int index, OnlineGame game) async {
    if (_firstCardIndex == null) {
      // First card
      if (!mounted) return;
      setState(() => _firstCardIndex = index);
    } else if (_secondCardIndex == null && index != _firstCardIndex) {
      // Second card
      if (!mounted) return;
      setState(() {
        _secondCardIndex = index;
        _isProcessing = true;
      });

      // Check for match
      final pairId1 = game.cardPairIds[_firstCardIndex!];
      final pairId2 = game.cardPairIds[index];
      final isMatch = pairId1 == pairId2;

      // Calculate score
      int scoreAwarded = 0;
      if (isMatch) {
        scoreAwarded = 100; // Base score for match
      }

      // Create move
      final move = GameMove(
        oddserId: ref.read(currentPlayerIdProvider) ?? '',
        card1Position: _firstCardIndex!,
        card2Position: index,
        pairId: pairId1,
        matched: isMatch,
        scoreAwarded: scoreAwarded,
        timestamp: DateTime.now(),
      );

      // Submit move
      await ref.read(onlineGameNotifierProvider.notifier).submitMove(
            widget.gameId,
            move,
          );

      // Only delay for non-matches (like local game behavior)
      // For matches, allow immediate next move for better UX
      if (!isMatch) {
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        // Short delay for match animation to show
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!mounted) return;  // Prevent setState after dispose
      setState(() {
        _firstCardIndex = null;
        _secondCardIndex = null;
        _isProcessing = false;
      });

      // Reset turn timer
      _startTurnTimer();
    }
  }

  Widget _buildGameOver(AppLocalizations l10n, OnlineGame game, String? myId) {
    final isWinner = game.winnerId == myId;
    final isDraw = game.winnerId == null;

    // Find opponent
    final opponent = game.players.firstWhere(
      (p) => p.oddserId != myId,
      orElse: () => game.players.last,
    );

    // Check if already friends
    final areFriends = myId != null
        ? ref.watch(areFriendsProvider((myId, opponent.oddserId)))
        : false;
    final hasPendingRequest = myId != null
        ? ref.watch(friendRequestPendingProvider((myId, opponent.oddserId)))
        : false;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDraw
                    ? Icons.handshake
                    : isWinner
                        ? Icons.emoji_events
                        : Icons.sentiment_dissatisfied,
                size: 80,
                color: isDraw
                    ? Colors.orange
                    : isWinner
                        ? Colors.amber
                        : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                isDraw
                    ? l10n.draw
                    : isWinner
                        ? l10n.youWin
                        : l10n.youLose,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDraw
                      ? Colors.orange
                      : isWinner
                          ? Colors.green
                          : Colors.red,
                ),
              ),
              const SizedBox(height: 16),

              // Final scores
              _buildFinalScores(game),
              const SizedBox(height: 24),

              // Add friend suggestion (only if not already friends)
              if (!areFriends && !hasPendingRequest && myId != null)
                _buildAddFriendSuggestion(l10n, opponent, myId),

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.goBack),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Return to matchmaking
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.playAgain),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddFriendSuggestion(
    AppLocalizations l10n,
    OnlinePlayer opponent,
    String myId,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.addFriend,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${opponent.displayName} ile arkadaş olmak ister misin?',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Get my display name from auth
                final authState = ref.read(authProvider);
                await ref.read(friendsNotifierProvider.notifier).sendFriendRequest(
                      fromUserId: myId,
                      toUserId: opponent.oddserId,
                      fromDisplayName: authState.displayName,
                      toDisplayName: opponent.displayName,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.friendRequestSent)),
                  );
                }
              },
              icon: const Icon(Icons.person_add, size: 18),
              label: Text(l10n.addFriend),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalScores(OnlineGame game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: game.rankedPlayers.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        final isFirst = index == 0;

        // Get player's profile for win/loss stats
        final profileAsync = ref.watch(onlineProfileProvider(player.oddserId));
        final profile = profileAsync.valueOrNull;

        return Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: player.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFirst ? Colors.amber : AppColors.cardBorder(context),
                width: isFirst ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFirst)
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                Text(
                  player.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  '${player.score}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: player.color,
                  ),
                ),
                // Show win/loss record
                if (profile != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${profile.wins}W - ${profile.losses}L',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameAbandoned(AppLocalizations l10n, OnlineGame game, String? myId) {
    // Check if I won (opponent left) or I lost (I left)
    final isWinner = game.winnerId == myId;
    final isDraw = game.winnerId == null;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWinner ? Icons.emoji_events : Icons.exit_to_app,
                size: 80,
                color: isWinner ? Colors.amber : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                isWinner ? l10n.youWin : l10n.youLose,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isWinner ? l10n.opponentLeft : l10n.youLeftGame,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 24),

              // Final scores
              _buildFinalScores(game),
              const SizedBox(height: 24),

              // Go back button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.goBack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showLeaveConfirmation(AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveGame),
        content: Text(l10n.leaveGameConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(onlineGameNotifierProvider.notifier)
                  .leaveGame(widget.gameId);
              if (context.mounted) Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Update player stats after game completion
  /// Stats are updated for all game modes (ranked and casual)
  /// Rating only changes for ranked games
  Future<void> _updateStatsAfterGame(OnlineGame game, String myId) async {
    if (game.players.length < 2) return;

    final myPlayer = game.players.firstWhere(
      (p) => p.oddserId == myId,
      orElse: () => game.players.first,
    );
    final opponent = game.players.firstWhere(
      (p) => p.oddserId != myId,
      orElse: () => game.players.last,
    );

    final isWinner = game.winnerId == myId;
    final isDraw = game.winnerId == null;
    final isRanked = game.mode == OnlineGameMode.ranked;

    debugPrint('🎮 Stats update: myId=$myId, winnerId=${game.winnerId}, isWinner=$isWinner, isDraw=$isDraw, isRanked=$isRanked');

    // Skip stats update for draws (no win/loss recorded)
    if (isDraw) {
      debugPrint('🎮 Draw game - skipping stats update');
      return;
    }

    // Calculate new rating only for ranked games
    int? newMyRating;
    if (isRanked) {
      if (isWinner) {
        final (winnerRating, _) = EloCalculator.calculateNewRatings(
          winnerRating: myPlayer.rating,
          loserRating: opponent.rating,
        );
        newMyRating = winnerRating;
      } else {
        final (_, loserRating) = EloCalculator.calculateNewRatings(
          winnerRating: opponent.rating,
          loserRating: myPlayer.rating,
        );
        newMyRating = loserRating;
      }
      debugPrint('🎮 Ranked game - new rating: $newMyRating');
    } else {
      debugPrint('🎮 Casual game - no rating change');
    }

    // Update stats (works for both ranked and casual)
    await ref.read(onlineProfileNotifierProvider.notifier).updateGameStats(
          oddserId: myId,
          isWin: isWinner,
          isRanked: isRanked,
          newRating: newMyRating,
        );

    debugPrint('🎮 Stats update complete for $myId');
  }
}
