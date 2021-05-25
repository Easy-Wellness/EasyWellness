import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential?> loginWithFacebook() async {
  // by default we request the email and the public profile...
  final LoginResult result = await FacebookAuth.instance.login();
  final AccessToken? accessToken = result.accessToken;
  if (accessToken == null) return null;
  final facebookAuthCredential =
  FacebookAuthProvider.credential(accessToken.token);

  /// Firebase will not set the User.emailVerified property to true if your
  /// user logs in with Facebook. Should your user login using a provider
  /// that verifies email (e.g. Google sign-in) then this will be set to true
  return await FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential);
}
