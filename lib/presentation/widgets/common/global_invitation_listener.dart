import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/entities/matchmaking.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../main.dart' show navigatorKey;
import '../../providers/auth_provider.dart';
import '../../providers/matchmaking_provider.dart';
import '../dialogs/game_invitation_dialog.dart';

/// Global invitation listener that works across all screens
/// Shows both a dialog and a local notification when a game invitation arrives
///
/// ARCHITECTURE: This widget is wrapped around the entire app in main.dart
/// to ensure invitations are received regardless of which screen the user is on.
///
/// CRITICAL: Uses [navigatorKey] from main.dart to show dialogs from any context.
/// This avoids the problem of dialogs not appearing when user is on different screens.
///
/// DUPLICATE PREVENTION: Uses [_shownInvitations] and [_pendingDialogs] sets
/// to prevent the same invitation from showing multiple dialogs.
class GlobalInvitationListener extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalInvitationListener({super.key, required this.child});

  @override
  ConsumerState<GlobalInvitationListener> createState() =>
      _GlobalInvitationListenerState();
}

class _GlobalInvitationListenerState
    extends ConsumerState<GlobalInvitationListener> {
  final Set<String> _shownInvitations = {};
  final Set<String> _pendingDialogs = {};

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAnonymous = authState.isAnonymous;

    // Only listen for logged-in non-anonymous users
    if (user != null && !isAnonymous) {
      ref.listen<AsyncValue<List<GameInvitation>>>(
        pendingInvitationsProvider(user.uid),
        (previous, next) {
          _handleInvitations(previous, next);
        },
      );
    }

    return widget.child;
  }

  void _handleInvitations(
    AsyncValue<List<GameInvitation>>? previous,
    AsyncValue<List<GameInvitation>> next,
  ) {
    final prevList = previous?.valueOrNull ?? [];
    final nextList = next.valueOrNull ?? [];

    // Check for new invitations
    for (final invitation in nextList) {
      final isNew = !prevList.any((inv) => inv.id == invitation.id);
      final alreadyShown = _shownInvitations.contains(invitation.id);
      final dialogPending = _pendingDialogs.contains(invitation.id);

      if (isNew && !alreadyShown && !dialogPending) {
        _shownInvitations.add(invitation.id);
        _pendingDialogs.add(invitation.id);
        _showInvitationSafely(invitation);
        break; // Only show one at a time
      }
    }

    // Clean up old invitations from tracking set
    _shownInvitations.removeWhere(
      (id) => !nextList.any((inv) => inv.id == id),
    );
  }

  /// Show invitation using navigatorKey for reliability
  void _showInvitationSafely(GameInvitation invitation) {
    // Use post frame callback to ensure we're not in build phase
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showInvitation(invitation);
    });
  }

  void _showInvitation(GameInvitation invitation) {
    // Use navigatorKey for reliable context access
    final navContext = navigatorKey.currentContext;
    if (navContext == null) {
      debugPrint('🔔 Navigator context not available for invitation dialog');
      _pendingDialogs.remove(invitation.id);
      return;
    }

    // Get localization
    final l10n = AppLocalizations.of(navContext);

    // Show local notification (works even if dialog fails)
    NotificationService().showLocalNotification(
      title: l10n?.gameInvitation ?? 'Game Invitation',
      body:
          '${invitation.fromDisplayName} ${l10n?.wantsToPlayWithYou ?? 'wants to play with you!'}',
      payload: 'invitation:${invitation.id}',
    );

    // Show dialog using navigatorKey
    showDialog(
      context: navContext,
      barrierDismissible: false,
      builder: (dialogContext) => GameInvitationDialog(invitation: invitation),
    ).then((_) {
      // Clean up pending dialog tracking
      _pendingDialogs.remove(invitation.id);
    });

    debugPrint('🔔 Invitation dialog shown for ${invitation.fromDisplayName}');
  }
}
