import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user (useful to check if already logged in)
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes (Log in / Log out events)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Return cleaner error messages for the user
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw 'Invalid email or password.';
      } else if (e.code == 'wrong-password') {
        throw 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        throw 'Please enter a valid email address.';
      } else {
        throw e.message ?? "An unknown error occurred";
      }
    } catch (e) {
      throw "An error occurred. Please check your connection.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign In with Google (supports web and mobile)
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On web, use signInWithPopup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw 'Sign in aborted by user.';
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw 'An account already exists with a different credential.';
      } else if (e.code == 'invalid-credential') {
        throw 'Invalid credentials received from Google.';
      } else {
        throw e.message ?? 'Google sign-in failed.';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}