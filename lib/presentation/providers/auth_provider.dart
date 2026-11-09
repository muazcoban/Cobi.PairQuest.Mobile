import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/moderation/name_filter.dart';
import '../../data/repositories/account_repository.dart';

/// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAnonymous;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAnonymous = false,
  });

  bool get isAuthenticated => user != null;
  bool get isGoogleLinked =>
      user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
  bool get isAppleLinked =>
      user?.providerData.any((p) => p.providerId == 'apple.com') ?? false;

  /// Whether the account has a name [displayName] can show. Sign in with
  /// Apple shares the name only the first time someone signs in to the app,
  /// and people can choose not to share it.
  bool get hasAccountName {
    final name = user?.displayName?.trim();
    return name != null && name.isNotEmpty && NameFilter.isAllowed(name);
  }

  /// The account name, public on the online profile, leaderboards, friend
  /// requests and invitations. Names the filter rejects are not used.
  String get displayName {
    if (hasAccountName) return user!.displayName!.trim();
    // Not the e-mail address: this name is public on the online profile.
    return 'Guest';
  }

  String? get email => user?.email;
  String? get photoUrl => user?.photoURL;
  String? get uid => user?.uid;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAnonymous,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

/// Outcome of [AuthNotifier.deleteAccount].
enum AccountDeletionResult { deleted, cancelled, wrongAccount, failed }

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AccountRepository _accountRepository = AccountRepository();
  late final GoogleSignIn _googleSignIn;

  static GoogleSignIn _createGoogleSignIn() {
    if (Platform.isIOS) {
      // iOS uses the CLIENT_ID from GoogleService-Info.plist
      return GoogleSignIn(
        clientId: '99735612337-pocr4s53e9nisft73v04p6p7es3o6o77.apps.googleusercontent.com',
      );
    }
    // Android uses the google-services.json automatically
    return GoogleSignIn();
  }

  AuthNotifier() : super(const AuthState()) {
    _googleSignIn = _createGoogleSignIn();
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      state = state.copyWith(
        user: user,
        isAnonymous: user?.isAnonymous ?? false,
        clearUser: user == null,
      );
    });
  }

  /// Sign in anonymously (automatic, background)
  Future<void> signInAnonymously() async {
    if (state.isAuthenticated) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _auth.signInAnonymously();
      state = state.copyWith(isLoading: false, isAnonymous: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // If user is anonymous, link the account
      if (state.isAnonymous && state.user != null) {
        await state.user!.linkWithCredential(credential);
      } else {
        await _auth.signInWithCredential(credential);
      }

      // Update profile with Google info
      await _updateProfileFromGoogle(googleUser);

      state = state.copyWith(isLoading: false, isAnonymous: false);
      return true;
    } on FirebaseAuthException catch (e) {
      // If linking fails because account exists, sign in instead
      if (e.code == 'credential-already-in-use') {
        try {
          final googleUser = await _googleSignIn.signIn();
          if (googleUser != null) {
            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await _auth.signInWithCredential(credential);
            // Update profile with Google info
            await _updateProfileFromGoogle(googleUser);
            state = state.copyWith(isLoading: false, isAnonymous: false);
            return true;
          }
        } catch (_) {}
      }
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign in with Apple (App Review 4.8: offered next to Google on iOS).
  /// Only the name is requested; people can keep their e-mail private.
  /// A guest account is linked, so its progress stays.
  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final provider = AppleAuthProvider()..addScope('name');
    try {
      if (state.isAnonymous && state.user != null) {
        try {
          await state.user!.linkWithProvider(provider);
        } on FirebaseAuthException catch (e) {
          // This Apple ID already has an account: sign in to that one.
          if (e.code != 'credential-already-in-use' || e.credential == null) rethrow;
          await _auth.signInWithCredential(e.credential!);
        }
      } else {
        await _auth.signInWithProvider(provider);
      }
      await _auth.currentUser?.reload();
      state = state.copyWith(
        user: _auth.currentUser,
        isLoading: false,
        isAnonymous: false,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.code == 'canceled' ? null : e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sets the account name for an account that has none, see
  /// [AuthState.hasAccountName]. Returns false if the name is not allowed
  /// or Firebase did not save it.
  Future<bool> setAccountName(String name) async {
    final user = _auth.currentUser;
    final trimmed = name.trim();
    if (user == null || trimmed.isEmpty || !NameFilter.isAllowed(trimmed)) {
      return false;
    }
    try {
      await user.updateDisplayName(trimmed);
      await user.reload();
      state = state.copyWith(user: _auth.currentUser);
      return true;
    } catch (e) {
      debugPrint('AuthNotifier: could not set the account name: $e');
      return false;
    }
  }

  /// Update Firebase user profile from Google account
  Future<void> _updateProfileFromGoogle(GoogleSignInAccount googleUser) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Update display name if not set or different
    if (user.displayName != googleUser.displayName && googleUser.displayName != null) {
      await user.updateDisplayName(googleUser.displayName);
    }

    // Update photo URL if not set or different
    if (user.photoURL != googleUser.photoUrl && googleUser.photoUrl != null) {
      await user.updatePhotoURL(googleUser.photoUrl);
    }

    // Reload user to get updated info
    await user.reload();
  }

  /// Link anonymous account with Google
  Future<bool> linkWithGoogle() async {
    if (!state.isAnonymous || state.user == null) {
      return signInWithGoogle();
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await state.user!.linkWithCredential(credential);

      // Update profile with Google info
      await _updateProfileFromGoogle(googleUser);

      state = state.copyWith(isLoading: false, isAnonymous: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      state = state.copyWith(isLoading: false, clearUser: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Delete the account and the data stored for it in Firestore.
  ///
  /// Firebase deletes only a user who signed in recently, so a Google or
  /// Apple user signs in again first. If that or a Firestore delete fails,
  /// the account stays and the user can try again.
  Future<AccountDeletionResult> deleteAccount() async {
    final user = state.user;
    if (user == null) return AccountDeletionResult.failed;
    final isGoogle = state.isGoogleLinked;
    final isApple = state.isAppleLinked;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      String? appleAuthorizationCode;
      if (isApple) {
        final credential =
            await user.reauthenticateWithProvider(AppleAuthProvider());
        appleAuthorizationCode = credential.additionalUserInfo?.authorizationCode;
      } else if (isGoogle && !await _reauthenticateWithGoogle(user)) {
        state = state.copyWith(isLoading: false);
        return AccountDeletionResult.cancelled;
      }

      await _accountRepository.deleteUserData(user.uid);

      // Apple requires apps to revoke Sign in with Apple tokens when the
      // account is deleted. A failure here must not keep the account.
      if (appleAuthorizationCode != null) {
        try {
          await _auth.revokeTokenWithAuthorizationCode(appleAuthorizationCode);
        } catch (e) {
          debugPrint('AuthNotifier: could not revoke the Apple token: $e');
        }
      }

      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        // A guest cannot sign in again. Its data is gone, so signing out
        // leaves only an empty anonymous user behind.
        if (e.code != 'requires-recent-login' || !user.isAnonymous) rethrow;
        await _auth.signOut();
      }

      if (isGoogle) {
        // Also revoke the app's access to the Google account.
        try {
          await _googleSignIn.disconnect();
        } catch (_) {
          await _googleSignIn.signOut();
        }
      }

      state = state.copyWith(isLoading: false, clearUser: true);
      return AccountDeletionResult.deleted;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled') {
        state = state.copyWith(isLoading: false);
        return AccountDeletionResult.cancelled;
      }
      state = state.copyWith(isLoading: false, error: e.message);
      return e.code == 'user-mismatch'
          ? AccountDeletionResult.wrongAccount
          : AccountDeletionResult.failed;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return AccountDeletionResult.failed;
    }
  }

  /// Returns false when the user closes the Google sign-in sheet.
  Future<bool> _reauthenticateWithGoogle(User user) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    await user.reauthenticateWithCredential(GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    ));
    return true;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Is anonymous provider
final isAnonymousProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAnonymous;
});
