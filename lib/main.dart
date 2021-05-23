import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:users/routes.dart';
import 'package:users/screens/error/error_screen.dart';
import 'package:users/screens/loading/loading_screen.dart';
import 'package:users/screens/login/login_screen.dart';
import 'package:users/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

/// State is persistent, therefore [Future] is only created once.
/// If [StatelessWidget] is used, in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire, which makes our application re-enter
/// loading state, which is undesired.
class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyWellness',
      theme: theme(),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorScreen();

          if (snapshot.connectionState == ConnectionState.done)
            return LoginScreen();

          return LoadingScreen();
        },
      ),
      routes: routes,
    );
  }
}
