import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:users/screens/login/send_auth_link_and_verify_screen.dart';
import 'package:users/services/auth_service/login_with_facebook.service.dart';
import 'package:users/services/auth_service/login_with_google.service.dart';
import 'package:users/utils/check_if_email_is_valid.dart';
import 'package:users/utils/push_new_page.dart';
import 'package:users/utils/show_custom_snack_bar.dart';
import 'package:users/widgets/or_divider.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: SvgPicture.asset("assets/icons/waves_bottom.svg"),
            ),
            Scaffold(
              /// See the white container with waves at the bottom
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('Login'),
              ),
              body: Body(),
            ),
          ],
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _emailInpController = TextEditingController();

  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _emailInpController.addListener(
      () => setState(() => _isEmpty = _emailInpController.text.isEmpty),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              "assets/icons/login.svg",
              height: size.height * 0.2,
            ),
            const SizedBox(height: 8),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ThemeData()
                    .colorScheme
                    .copyWith(primary: Colors.blueGrey[700]!),
              ),
              child: TextField(
                controller: _emailInpController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Your email address',
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon: _isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => _emailInpController.clear(),
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.blueGrey[700]!),
              onPressed: _isEmpty
                  ? null
                  : () {
                      final email = _emailInpController.text;
                      final emailErr = checkIfEmailIsValid(email);
                      if (emailErr != null)
                        return showCustomSnackBar(context, emailErr);
                      pushNewPage<void>(
                          context, SendAuthLinkAndVerifyScreen(email: email));
                    },
              child: const Text('Next'),
            ),
            OrDivider(),
            ElevatedButton.icon(
              onPressed: () => loginWithGoogle(),
              style: ElevatedButton.styleFrom(primary: Colors.white60),
              icon: SvgPicture.asset(
                'assets/icons/google_icon.svg',
                height: 24,
              ),
              label: Text(
                'Continue with Google',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => loginWithFacebook(context),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              icon: SvgPicture.asset(
                'assets/icons/facebook_icon.svg',
                height: 24,
                color: Colors.white,
              ),
              label: Text('Continue with Facebook'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailInpController.dispose();
    super.dispose();
  }
}
