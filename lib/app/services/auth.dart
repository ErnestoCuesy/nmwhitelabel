import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class UserAuth {
  UserAuth({
    required this.uid,
    required this.photoUrl,
    required this.displayName,
    required this.email,
    required this.isAnonymous,
    required this.isEmailVerified,
  });
  final String uid;
  final String? photoUrl;
  final String? displayName;
  final String? email;
  final bool isAnonymous;
  final bool isEmailVerified;
}

abstract class AuthBase {
  Stream<UserAuth?> get onAuthStateChanged;
  Future<UserAuth?> currentUser();
  Future<UserAuth?> signInAnonymously();
  Future<UserAuth?> signInWithEmailAndPassword(String? email, String? password);
  Future<void> createUserWithEmailAndPassword(String? email, String? password);
  Future<void> resetPassword(String? email);
  Future<void> signOut();
  Future<void> convertUserWithEmail(
      String? email, String? password, String? name);
  Future<void> updateUserName(String name, User currentUser);
  Future<bool> userIsAnonymous();
  Future<bool> userEmailVerified();
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
  Future<String?> userEmail();
  Future<void> deleteUser();
}

class Auth implements AuthBase {
  final _fireBaseAuth = FirebaseAuth.instance;
  final String emailVerificationMessage =
      'Please verify your email address by clicking on the link emailed to you. Check your inbox and spam folders!';
  final String passwordResetMessage =
      'A password reset link has been emailed to you. Please click on it to enter your new password and try to sign in again.';

  UserAuth? _userFromFirebase(User? user) {
    print('FirebaseUser => ${user!.email}');
    return UserAuth(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        isAnonymous: user.isAnonymous,
        isEmailVerified: user.emailVerified);
  }

  @override
  Stream<UserAuth?> get onAuthStateChanged {
    return _fireBaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<UserAuth?> currentUser() async {
    final user = _fireBaseAuth.currentUser!;
    return _userFromFirebase(user);
  }

  @override
  Future<UserAuth?> signInAnonymously() async {
    final authResult = await _fireBaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<UserAuth?> signInWithEmailAndPassword(
      String? email, String? password) async {
    User? userInfo;
    try {
      final credential = await _fireBaseAuth.signInWithEmailAndPassword(
          email: email!, password: password!);
      userInfo = credential.user;
      if (!userInfo!.emailVerified) {
        throw PlatformException(
            code: 'EMAIL_NOT_VERIFIED', message: emailVerificationMessage);
      }
      return _userFromFirebase(userInfo);
    } on FirebaseAuthException catch (e) {
      print(e);
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword(
      String? email, String? password) async {
    try {
      final authResult = await _fireBaseAuth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      authResult.user!.sendEmailVerification();
      throw PlatformException(
          code: 'EMAIL_NOT_VERIFIED', message: emailVerificationMessage);
    } on FirebaseAuthException catch (e) {
      print(e);
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
    // Hotmail filters verification email sent by Firebase - avoid Hotmail
  }

  @override
  Future<void> resetPassword(String? email) async {
    try {
      await _fireBaseAuth.sendPasswordResetEmail(email: email!);
      throw PlatformException(
          code: 'PASSWORD_RESET', message: passwordResetMessage);
    } catch (e) {
      final PlatformException pe = e as PlatformException;
      print(e);
      if (pe.code == 'user-not-found') {
        throw PlatformException(
          code: 'ERROR_USER_NOT_FOUND',
          message: e.message,
        );
      } else {
        throw PlatformException(
            code: 'PASSWORD_RESET', message: passwordResetMessage);
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _fireBaseAuth.signOut();
  }

  @override
  Future<void> convertUserWithEmail(
      String? email, String? password, String? name) async {
    final currentUser = _fireBaseAuth.currentUser!;
    final credential =
        EmailAuthProvider.credential(email: email!, password: password!);
    try {
      await currentUser.linkWithCredential(credential);
      await updateUserName(name, currentUser);
    } on FirebaseAuthException catch (e) {
      print(e);
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }

  @override
  Future<void> updateUserName(String? name, User currentUser) async {
    await currentUser.updateDisplayName(name);
    await currentUser.reload();
  }

  @override
  Future<bool> userIsAnonymous() async {
    return _fireBaseAuth.currentUser!.isAnonymous;
  }

  @override
  Future<bool> userEmailVerified() async {
    return _fireBaseAuth.currentUser!.emailVerified;
  }

  @override
  Future<void> sendEmailVerification() async {
    _fireBaseAuth.currentUser!.sendEmailVerification();
  }

  @override
  Future<void> reloadUser() async {
    try {
      _fireBaseAuth.currentUser!.reload();
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<String?> userEmail() async {
    return _fireBaseAuth.currentUser!.email;
  }

  @override
  Future<void> deleteUser() async {
    try {
      _fireBaseAuth.currentUser!.delete();
    } catch (e) {
      print(e);
    }
  }
}
