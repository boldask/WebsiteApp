import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

/// Service for handling Firebase Authentication operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user.
  User? get currentUser => _auth.currentUser;

  /// Get current user ID.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated.
  bool get isAuthenticated => _auth.currentUser != null;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Create account with email and password.
  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _createUserDocument(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Create user document in Firestore.
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
      'displayName': displayName,
      'email': email,
      'photoUrl': null,
      'location': null,
      'polls': [],
      'circles': [],
      'projects': [],
      'followers': [],
      'following': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update user display name.
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    if (currentUserId != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({'displayName': displayName});
    }
  }

  /// Update user photo URL.
  Future<void> updatePhotoUrl(String photoUrl) async {
    await _auth.currentUser?.updatePhotoURL(photoUrl);
    if (currentUserId != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({'photoUrl': photoUrl});
    }
  }

  /// Delete user account.
  Future<void> deleteAccount() async {
    final uid = currentUserId;
    if (uid != null) {
      // Delete user document
      await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
      // Delete Firebase Auth account
      await _auth.currentUser?.delete();
    }
  }

  /// Handle Firebase Auth errors.
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
