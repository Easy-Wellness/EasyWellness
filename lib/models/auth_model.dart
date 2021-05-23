import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum LoginState {
  signedOut,
  loggedIn,
}

class AuthModel extends ChangeNotifier {
  AuthModel() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = LoginState.loggedIn;
      } else {
        _loginState = LoginState.signedOut;
      }
      notifyListeners();
    });
  }

  LoginState _loginState = LoginState.signedOut;

  LoginState get loginState => _loginState;

  void registerAccount(String email, String displayName, String password,
      void Function(FirebaseAuthException e) errorCb) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateProfile(displayName: displayName);
    } on FirebaseAuthException catch (e) {
      errorCb(e);
    }
  }

  void signOut() => FirebaseAuth.instance.signOut();
}
