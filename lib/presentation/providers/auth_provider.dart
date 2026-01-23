import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  String get displayName {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    }
    if (user?.email != null) {
      return user!.email!.split('@').first;
    }
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

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  /// Delete account
  Future<bool> deleteAccount() async {
    if (state.user == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await state.user!.delete();
      await _googleSignIn.signOut();
      state = state.copyWith(isLoading: false, clearUser: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
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
