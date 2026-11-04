import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/moderation_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/moderation_provider.dart';

/// Report and block another player (App Review 1.2). Offered wherever another
/// player's name appears: leaderboards, friends, requests, invitations,
/// search results and online games.

const String reportMenuValue = 'report';
const String blockMenuValue = 'block';

/// Menu entries to add to an existing player menu.
List<PopupMenuEntry<String>> playerSafetyMenuItems(AppLocalizations l10n) => [
      PopupMenuItem(
        value: reportMenuValue,
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, size: 20),
            const SizedBox(width: 8),
            Text(l10n.reportPlayer),
          ],
        ),
      ),
      PopupMenuItem(
        value: blockMenuValue,
        child: Row(
          children: [
            const Icon(Icons.block, size: 20),
            const SizedBox(width: 8),
            Text(l10n.blockPlayer),
          ],
        ),
      ),
    ];

/// Runs the report or block entry chosen from [playerSafetyMenuItems].
/// Returns false for any other menu value.
bool handlePlayerSafetyAction(
  String value,
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required ReportSource source,
}) {
  switch (value) {
    case reportMenuValue:
      showReportPlayerDialog(context, ref,
          userId: userId, displayName: displayName, source: source);
      return true;
    case blockMenuValue:
      confirmBlockPlayer(context, ref, userId: userId, displayName: displayName);
      return true;
  }
  return false;
}

/// A "more" button with Report and Block, for rows that have no menu yet.
class PlayerSafetyButton extends ConsumerWidget {
  const PlayerSafetyButton({
    super.key,
    required this.userId,
    required this.displayName,
    required this.source,
    this.color,
  });

  final String userId;
  final String displayName;
  final ReportSource source;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: l10n.playerOptions,
      icon: Icon(Icons.more_horiz, color: color),
      onSelected: (value) => handlePlayerSafetyAction(value, context, ref,
          userId: userId, displayName: displayName, source: source),
      itemBuilder: (_) => playerSafetyMenuItems(l10n),
    );
  }
}

/// Returns true when the player was also blocked.
Future<bool> showReportPlayerDialog(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String displayName,
  required ReportSource source,
}) async {
  final uid = ref.read(authProvider).uid;
  if (uid == null || uid == userId) return false;
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);

  final choice = await showDialog<(ReportReason, bool)>(
    context: context,
    builder: (_) => _ReportDialog(displayName: displayName),
  );
  if (choice == null) return false;
  final (reason, alsoBlock) = choice;

  final repository = ref.read(moderationRepositoryProvider);
  try {
    await repository.reportPlayer(
      reporterId: uid,
      reportedUserId: userId,
      reportedName: displayName,
      reason: reason,
      source: source,
    );
    if (alsoBlock) {
      await repository.blockPlayer(
          uid: uid, blockedId: userId, displayName: displayName);
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
    return alsoBlock;
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportFailed)));
    return false;
  }
}

/// Returns true when the player was blocked.
Future<bool> confirmBlockPlayer(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String displayName,
}) async {
  final uid = ref.read(authProvider).uid;
  if (uid == null || uid == userId) return false;
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.blockPlayerTitle(displayName)),
      content: Text(l10n.blockPlayerDesc),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        // No destructive style: people chose Block on purpose (HIG Alerts).
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.blockPlayer),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  try {
    await ref
        .read(moderationRepositoryProvider)
        .blockPlayer(uid: uid, blockedId: userId, displayName: displayName);
    messenger.showSnackBar(
        SnackBar(content: Text(l10n.playerBlocked(displayName))));
    return true;
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.blockFailed)));
    return false;
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.displayName});

  final String displayName;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  ReportReason? _reason;
  bool _alsoBlock = false;

  String _label(AppLocalizations l10n, ReportReason reason) {
    switch (reason) {
      case ReportReason.offensiveName:
        return l10n.reportReasonOffensiveName;
      case ReportReason.offensivePhoto:
        return l10n.reportReasonOffensivePhoto;
      case ReportReason.harassment:
        return l10n.reportReasonHarassment;
      case ReportReason.cheating:
        return l10n.reportReasonCheating;
      case ReportReason.other:
        return l10n.reportReasonOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.reportPlayerTitle(widget.displayName)),
      contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
      content: SingleChildScrollView(
        child: RadioGroup<ReportReason>(
          groupValue: _reason,
          onChanged: (value) => setState(() => _reason = value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final reason in ReportReason.values)
                RadioListTile<ReportReason>(
                  value: reason,
                  title: Text(_label(l10n, reason)),
                ),
              const Divider(),
              CheckboxListTile(
                value: _alsoBlock,
                onChanged: (value) => setState(() => _alsoBlock = value ?? false),
                title: Text(l10n.reportAlsoBlock),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _reason == null
              ? null
              : () => Navigator.of(context).pop((_reason!, _alsoBlock)),
          child: Text(l10n.reportSend),
        ),
      ],
    );
  }
}
