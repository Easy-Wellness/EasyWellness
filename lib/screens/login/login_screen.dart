import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:users/Components/or_divider.dart';
import 'package:users/utils/loginWithGoogle.dart';

class LoginScreen extends StatelessWidget {
  static String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Body(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _phoneInpController = TextEditingController();

  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _phoneInpController.addListener(
      () => setState(() => _isEmpty = _phoneInpController.text.isEmpty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...[
              TextField(
                controller: _phoneInpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text('+84'),
                  ),
                  suffixIcon: _isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => _phoneInpController.clear(),
                          icon: Icon(Icons.clear),
                        ),
                ),
              ),
              ElevatedButton(
                onPressed: _isEmpty ? null : () => {},
                child: Text('Next'),
              ),
              OrDivider(),
              ElevatedButton.icon(
                onPressed: () => loginWithGoogle(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white60,
                ),
                icon: SvgPicture.asset(
                  'assets/icons/google-icon.svg',
                  height: 24,
                ),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                icon: SvgPicture.asset(
                  'assets/icons/facebook-icon.svg',
                  height: 24,
                  color: Colors.white,
                ),
                label: Text('Continue with Facebook'),
              ),
              ElevatedButton.icon(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(primary: Colors.black),
                icon: SvgPicture.asset(
                  'assets/icons/apple-icon.svg',
                  height: 24,
                  color: Colors.white,
                ),
                label: Text('Continue with Apple'),
              )
            ].expand(
              (widget) => [
                widget,
                SizedBox(
                  height: 8,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneInpController.dispose();
    super.dispose();
  }
}
