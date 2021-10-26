import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:users/routes.dart';
import 'package:users/theme.dart';

import 'screens/explore/explore_screen.dart';
import 'screens/login/login_screen.dart';

const _useFirebaseEmulatorSuite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      // ignore: invalid_return_type_for_catch_error
      .catchError((_) => print('Cannot initialize Firebase'));

  if (_useFirebaseEmulatorSuite) {
    await FirebaseAuth.instance.useEmulator('http://localhost:9099');

    /// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    /// This is only called once after the widget is mounted.
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => FirebaseAuth.instance.authStateChanges().listen((User? user) {
        NavigationService.navigatorKey.currentState!
            .popUntil((route) => route.isFirst);
        if (user == null)
          NavigationService.navigatorKey.currentState!
              .pushReplacementNamed(LoginScreen.routeName);
        else
          NavigationService.navigatorKey.currentState!
              .pushReplacementNamed(ExploreScreen.routeName);
      }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      title: 'Easy Wellness',
      theme: theme(),
      home: LoginScreen(),
      routes: routes,
    );
  }
}

/// A Global navigator key shared to all widgets below MaterialApp. This is
/// extremely useful if u want to show a snackbar that does not depend on an
/// ephemeral BuildContext, which might quickly get removed when
/// Navigator.popUntil() is called.
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
