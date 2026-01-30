import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/matchmaking.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matchmaking_provider.dart';
import '../../providers/online_game_provider.dart';
import '../../screens/online/online_game_screen.dart';

/// Dialog shown when receiving a game invitation
///
/// CRITICAL: When accepting invitation, must set [currentPlayerIdProvider]
/// BEFORE navigating to game screen. Otherwise turn detection fails (myId=null).
/// See [_accept] method for implementation.
class GameInvitationDialog extends ConsumerWidget {
  final GameInvitation invitation;

  const GameInvitationDialog({super.key, required this.invitation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_esports,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              l10n.gameInvitation,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),

            // Sender info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: invitation.fromPhotoUrl != null
                      ? NetworkImage(invitation.fromPhotoUrl!)
                      : null,
                  child: invitation.fromPhotoUrl == null
                      ? Text(
                          invitation.fromDisplayName.isNotEmpty
                              ? invitation.fromDisplayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.fromDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      l10n.wantsToPlayWithYou,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Game info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grid_view,
                    size: 20,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.level} ${invitation.level}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _decline(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(color: Colors.red.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.decline),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _accept(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _accept(BuildContext context, WidgetRef ref) async {
    // Get the navigator before popping
    final navigator = Navigator.of(context);

    // Pop the dialog first
    navigator.pop();

    debugPrint('📨 Accepting invitation: ${invitation.id}');

    // IMPORTANT: Set currentPlayerIdProvider BEFORE entering game
    // This ensures turn detection works correctly
    final authState = ref.read(authProvider);
    final userId = authState.user?.uid;
    if (userId != null) {
      ref.read(currentPlayerIdProvider.notifier).state = userId;
      debugPrint('📨 Set currentPlayerIdProvider to: $userId');
    }

    final gameId = await ref
        .read(invitationNotifierProvider.notifier)
        .acceptInvitation(invitation.id);

    debugPrint('📨 Accept result: gameId=$gameId');

    if (gameId != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => OnlineGameScreen(gameId: gameId),
        ),
      );
    } else {
      debugPrint('📨 Failed to accept invitation - gameId is null');
    }
  }

  void _decline(BuildContext context, WidgetRef ref) {
    ref.read(invitationNotifierProvider.notifier).declineInvitation(invitation.id);
    Navigator.of(context).pop();
  }
}

/// Widget to show pending invitations as a notification badge
class InvitationsBadge extends ConsumerWidget {
  final String userId;
  final Widget child;

  const InvitationsBadge({
    super.key,
    required this.userId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsAsync = ref.watch(pendingInvitationsProvider(userId));

    return invitationsAsync.when(
      data: (invitations) {
        if (invitations.isEmpty) return child;

        return Badge(
          label: Text('${invitations.length}'),
          child: child,
        );
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}

/// Listener widget that shows invitation dialog when new invitations arrive
class InvitationListener extends ConsumerWidget {
  final String userId;
  final Widget child;

  const InvitationListener({
    super.key,
    required this.userId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('📨 InvitationListener build for user: $userId');
    ref.listen<AsyncValue<List<GameInvitation>>>(
      pendingInvitationsProvider(userId),
      (previous, next) {
        final prevList = previous?.valueOrNull ?? [];
        final nextList = next.valueOrNull ?? [];

        debugPrint('📨 InvitationListener: prev=${prevList.length}, next=${nextList.length}');

        // Check for new invitations
        for (final invitation in nextList) {
          final isNew = !prevList.any((inv) => inv.id == invitation.id);
          debugPrint('📨 Checking invitation ${invitation.id} from ${invitation.fromDisplayName}: isNew=$isNew');
          if (isNew) {
            // Show dialog for new invitation
            debugPrint('📨 Showing invitation dialog for ${invitation.fromDisplayName}');
            showDialog(
              context: context,
              builder: (context) => GameInvitationDialog(invitation: invitation),
            );
            break; // Only show one at a time
          }
        }
      },
    );

    return child;
  }
}
