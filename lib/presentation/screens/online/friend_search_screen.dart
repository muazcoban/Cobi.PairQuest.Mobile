import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friends_provider.dart';

/// Search and add friends screen
class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final currentUserId = ref.read(authProvider).user?.uid;

      // Search with multiple case variations for better matching
      final queryLower = query.toLowerCase();
      final queryUpper = query.toUpperCase();
      final queryCapitalized = query.isNotEmpty
          ? query[0].toUpperCase() + query.substring(1).toLowerCase()
          : query;

      // Perform multiple searches with different case variations
      final futures = [
        firestore
            .collection('users')
            .where('displayName', isGreaterThanOrEqualTo: query)
            .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
            .limit(10)
            .get(),
        firestore
            .collection('users')
            .where('displayName', isGreaterThanOrEqualTo: queryLower)
            .where('displayName', isLessThanOrEqualTo: '$queryLower\uf8ff')
            .limit(10)
            .get(),
        firestore
            .collection('users')
            .where('displayName', isGreaterThanOrEqualTo: queryCapitalized)
            .where('displayName', isLessThanOrEqualTo: '$queryCapitalized\uf8ff')
            .limit(10)
            .get(),
        firestore
            .collection('users')
            .where('displayName', isGreaterThanOrEqualTo: queryUpper)
            .where('displayName', isLessThanOrEqualTo: '$queryUpper\uf8ff')
            .limit(10)
            .get(),
      ];

      final results = await Future.wait(futures);

      // Combine and deduplicate results using a map
      final userMap = <String, Map<String, dynamic>>{};
      for (final result in results) {
        for (final doc in result.docs) {
          if (doc.id != currentUserId && !userMap.containsKey(doc.id)) {
            userMap[doc.id] = {'id': doc.id, ...doc.data()};
          }
        }
      }

      setState(() {
        _searchResults = userMap.values.toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.addFriend),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchByName,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) => _search(value),
            ),
          ),

          // Results
          Expanded(
            child: _buildContent(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.red.shade400)),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return _buildSearchHint(l10n);
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noUsersFound,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserSearchTile(user: user);
      },
    );
  }

  Widget _buildSearchHint(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchForFriends,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.enterAtLeast3Chars,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// User search result tile
class _UserSearchTile extends ConsumerWidget {
  final Map<String, dynamic> user;

  const _UserSearchTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = ref.watch(authProvider).user?.uid ?? '';
    final userId = user['id'] as String;
    final displayName = user['displayName'] as String? ?? 'Unknown';
    final photoUrl = user['photoUrl'] as String?;
    final rating = user['rating'] as int? ?? 1200;

    // Check friendship status
    final areFriends = ref.watch(areFriendsProvider((currentUserId, userId)));
    final requestPending = ref.watch(friendRequestPendingProvider((currentUserId, userId)));

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
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
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
        subtitle: Text(
          'Rating: $rating',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: _buildActionButton(
          context,
          ref,
          l10n,
          userId,
          areFriends,
          requestPending,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String userId,
    bool areFriends,
    bool requestPending,
  ) {
    if (areFriends) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              l10n.friends,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (requestPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.pending,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _sendFriendRequest(context, ref, l10n, userId),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(l10n.addFriend),
    );
  }

  void _sendFriendRequest(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String toUserId,
  ) async {
    final authState = ref.read(authProvider);
    final currentUserId = authState.user?.uid;
    if (currentUserId == null) return;

    // Get target user's display name from search results
    final toDisplayName = user['displayName'] as String?;

    try {
      await ref.read(friendsNotifierProvider.notifier).sendFriendRequest(
            fromUserId: currentUserId,
            toUserId: toUserId,
            fromDisplayName: authState.displayName,
            toDisplayName: toDisplayName,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.friendRequestSent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorOccurred}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
