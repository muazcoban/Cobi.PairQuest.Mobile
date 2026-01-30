import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/matchmaking.dart';
import '../../../domain/entities/online_player.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friends_provider.dart';
import '../../providers/matchmaking_provider.dart';
import '../../providers/online_game_provider.dart';
import '../../providers/online_profile_provider.dart';
import '../../widgets/dialogs/game_invitation_dialog.dart';
import 'friend_search_screen.dart';
import 'online_game_screen.dart';

/// Friends list screen
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final userId = authState.user?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.friends)),
        body: Center(child: Text(l10n.loginRequired)),
      );
    }

    // Wrap with InvitationListener to receive game invitations
    return InvitationListener(
      userId: userId,
      child: DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: Text(l10n.friends),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FriendSearchScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.friendsList),
              Tab(text: l10n.friendRequests),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary(context),
          ),
        ),
        body: TabBarView(
          children: [
            _FriendsListTab(userId: userId),
            _RequestsTab(userId: userId),
          ],
        ),
      ),
    ),
    );
  }
}

/// Friends list tab
class _FriendsListTab extends ConsumerWidget {
  final String userId;

  const _FriendsListTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final friendsAsync = ref.watch(friendsListProvider(userId));

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return _buildEmptyState(context, l10n);
        }
        return ListView.builder(
          key: ValueKey('friends_list_$userId'),  // Performance: preserve scroll position
          padding: const EdgeInsets.all(16),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friendship = friends[index];
            final friendId = friendship.getFriendId(userId);
            return _FriendTile(
              key: ValueKey('friend_$friendId'),  // Performance: efficient rebuilds
              friendId: friendId,
              friendship: friendship,
              currentUserId: userId,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noFriendsYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFriendsToPlay,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FriendSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: Text(l10n.addFriend),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Friend requests tab
class _RequestsTab extends ConsumerWidget {
  final String userId;

  const _RequestsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final requestsAsync = ref.watch(pendingFriendRequestsProvider(userId));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 64,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noFriendRequests,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          key: ValueKey('requests_list_$userId'),  // Performance: preserve scroll position
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _FriendRequestTile(
              key: ValueKey('request_${request.id}'),  // Performance: efficient rebuilds
              request: request,
              currentUserId: userId,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
    );
  }
}

/// Friend tile widget
class _FriendTile extends ConsumerWidget {
  final String friendId;
  final Friendship friendship;
  final String currentUserId;

  const _FriendTile({
    super.key,
    required this.friendId,
    required this.friendship,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Get friend's profile for online status and display name
    final friendProfileAsync = ref.watch(onlineProfileProvider(friendId));
    final friendProfile = friendProfileAsync.valueOrNull;
    final isOnline = friendProfile?.status == ConnectionStatus.online;

    // Get display name from friendship or profile
    final displayName = friendship.getDisplayName(currentUserId) ??
        friendProfile?.displayName ??
        'User ${friendId.substring(0, 4)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          backgroundImage: friendProfile?.photoUrl != null
              ? NetworkImage(friendProfile!.photoUrl!)
              : null,
          child: friendProfile?.photoUrl == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOnline ? l10n.online : l10n.offline,
              style: TextStyle(
                fontSize: 12,
                color: isOnline ? Colors.green : AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textSecondary(context),
          ),
          onSelected: (value) async {
            if (value == 'invite') {
              _inviteToGame(context, ref, l10n);
            } else if (value == 'remove') {
              _removeFriend(context, ref, l10n);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'invite',
              child: Row(
                children: [
                  const Icon(Icons.sports_esports, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.inviteToGame),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 20, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Text(l10n.removeFriend, style: TextStyle(color: Colors.red.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _inviteToGame(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user == null) return;

    final invitationId = await ref.read(invitationNotifierProvider.notifier).sendInvitation(
      fromUserId: user.uid,
      fromDisplayName: authState.displayName,
      fromPhotoUrl: user.photoURL,
      toUserId: friendId,
    );

    if (!context.mounted) return;

    if (invitationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invitationFailed),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show waiting dialog and watch for acceptance
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _InvitationWaitingDialog(
        invitationId: invitationId,
        friendName: friendship.getDisplayName(friendId) ?? 'Friend',
      ),
    );
  }

  void _removeFriend(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFriend),
        content: Text(l10n.removeFriendConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(friendsNotifierProvider.notifier).removeFriend(friendship.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.friendRemoved)),
        );
      }
    }
  }
}

/// Friend request tile
class _FriendRequestTile extends ConsumerWidget {
  final Friendship request;
  final String currentUserId;

  const _FriendRequestTile({
    super.key,
    required this.request,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final senderId = request.requestedBy;

    // Get sender's profile for display name
    final senderProfileAsync = ref.watch(onlineProfileProvider(senderId));
    final senderProfile = senderProfileAsync.valueOrNull;

    // Get display name from request or profile
    final displayName = request.getRequesterDisplayName() ??
        senderProfile?.displayName ??
        'User ${senderId.substring(0, 4)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: senderProfile?.photoUrl != null
                ? NetworkImage(senderProfile!.photoUrl!)
                : null,
            child: senderProfile?.photoUrl == null
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  l10n.wantsToBeYourFriend,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _acceptRequest(context, ref, l10n),
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: l10n.accept,
              ),
              IconButton(
                onPressed: () => _declineRequest(context, ref, l10n),
                icon: Icon(Icons.cancel, color: Colors.red.shade400),
                tooltip: l10n.decline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _acceptRequest(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    await ref.read(friendsNotifierProvider.notifier).acceptFriendRequest(request.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.friendRequestAccepted),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _declineRequest(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    await ref.read(friendsNotifierProvider.notifier).declineFriendRequest(request.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.friendRequestDeclined)),
      );
    }
  }
}

/// Dialog shown while waiting for invitation to be accepted
///
/// CRITICAL: When invitation is accepted and navigating to game,
/// must set [currentPlayerIdProvider] BEFORE navigation.
/// Otherwise turn detection fails for the sender (myId=null).
class _InvitationWaitingDialog extends ConsumerWidget {
  final String invitationId;
  final String friendName;

  const _InvitationWaitingDialog({
    required this.invitationId,
    required this.friendName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final invitationAsync = ref.watch(watchInvitationProvider(invitationId));

    // Listen for invitation status changes
    ref.listen<AsyncValue<GameInvitation?>>(
      watchInvitationProvider(invitationId),
      (previous, next) {
        final invitation = next.valueOrNull;
        if (invitation == null) return;

        if (invitation.status == InvitationStatus.accepted &&
            invitation.gameId != null &&
            invitation.gameId != 'CREATING') {
          // IMPORTANT: Set currentPlayerIdProvider BEFORE entering game
          // This ensures turn detection works correctly for the sender
          final authState = ref.read(authProvider);
          final userId = authState.user?.uid;
          if (userId != null) {
            ref.read(currentPlayerIdProvider.notifier).state = userId;
            debugPrint('📨 Sender: Set currentPlayerIdProvider to: $userId');
          }

          // Invitation accepted! Navigate to game
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OnlineGameScreen(gameId: invitation.gameId!),
            ),
          );
        } else if (invitation.status == InvitationStatus.declined) {
          // Invitation declined
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.invitationDeclined),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (invitation.isExpired) {
          // Invitation expired
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.invitationExpired),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              l10n.waitingForResponse,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              '${l10n.invitationSentTo} $friendName',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
