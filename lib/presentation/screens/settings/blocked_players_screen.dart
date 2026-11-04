import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/moderation_provider.dart';

/// Players the user blocked, with a way to unblock them.
class BlockedPlayersScreen extends ConsumerWidget {
  const BlockedPlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final uid = ref.watch(authProvider).uid;
    final blocked = uid == null
        ? const AsyncValue.data(<Never>[])
        : ref.watch(blockedPlayersProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(l10n.blockedPlayers)),
      body: blocked.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errorOccurred)),
        data: (players) => players.isEmpty
            ? Center(
                child: Text(
                  l10n.noBlockedPlayers,
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: players.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ListTile(
                    leading: const Icon(Icons.block),
                    title: Text(player.displayName),
                    trailing: TextButton(
                      onPressed: () => ref
                          .read(moderationRepositoryProvider)
                          .unblockPlayer(uid: uid!, blockedId: player.userId),
                      child: Text(l10n.unblock),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
