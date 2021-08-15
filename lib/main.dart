import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:users/routes.dart';
import 'package:users/theme.dart';

import 'screens/error/error_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

/// State is persistent and not rebuilt, therefore [Future] is only created once.
/// If [StatelessWidget] is used, in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and makes our app re-enter the
/// loading state, which is undesired.
class _AppState extends State<App> {
  final Future<FirebaseApp> _initFirebaseSdk = Firebase.initializeApp();
  final _navigatorKey = new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      title: 'Easy Wellness',
      theme: theme(),
      home: FutureBuilder(
          future: _initFirebaseSdk,
          builder: (_, snapshot) {
            if (snapshot.hasError) return ErrorScreen();

            if (snapshot.connectionState == ConnectionState.done) {
              // Assign listener after the SDK is initialized successfully
              FirebaseAuth.instance.authStateChanges().listen((User? user) {
                if (user == null)
                  _navigatorKey.currentState!
                      .pushReplacementNamed(LoginScreen.routeName);
                else
                  _navigatorKey.currentState!
                      .pushReplacementNamed(ExploreScreen.routeName);
              });
            }

            return LoadingScreen();
          }),
      routes: routes,
    );
  }
}
