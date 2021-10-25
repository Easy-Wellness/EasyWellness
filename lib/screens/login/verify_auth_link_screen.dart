import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users/services/auth_service/send_sign_in_link_to_email.dart';
import 'package:users/utils/show_custom_snack_bar.dart';

class VerifyAuthLinkScreen extends StatefulWidget {
  const VerifyAuthLinkScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  final String email;

  @override
  State<VerifyAuthLinkScreen> createState() => _VerifyAuthLinkScreenState();
}

class _VerifyAuthLinkScreenState extends State<VerifyAuthLinkScreen> {
  final _authLinkInpController = TextEditingController();

  bool _isEmpty = true;

  @override
  void initState() {
    _authLinkInpController.addListener(
      () => setState(() => _isEmpty = _authLinkInpController.text.isEmpty),
    );

    WidgetsBinding.instance!.addPostFrameCallback((_) => _sendEmailAuthLink());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy & Paste the email link'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "A link is sent to your email address",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 32),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ThemeData()
                    .colorScheme
                    .copyWith(primary: Colors.blueGrey[700]!),
              ),
              child: TextField(
                controller: _authLinkInpController,
                keyboardType: TextInputType.url,
                showCursor: false,
                decoration: InputDecoration(
                  hintText: _isEmpty
                      ? 'Link from email'
                      : _authLinkInpController.text,
                  suffixIcon: TextButton(
                    onPressed: () async {
                      final clipboardData =
                          await Clipboard.getData('text/plain');
                      if (clipboardData != null && clipboardData.text != null)
                        _authLinkInpController.text = clipboardData.text!;
                    },
                    child: const Text('Paste'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.link),
              style: ElevatedButton.styleFrom(primary: Colors.blueGrey[700]!),
              onPressed: _isEmpty
                  ? null
                  : () {
                      final authLink = _authLinkInpController.text;
                      if (authLink.trim().isEmpty) {
                        _authLinkInpController.clear();
                        return showCustomSnackBar(
                            context, 'A link is required');
                      }
                      final linkIsValid =
                          Uri.tryParse(authLink)?.hasAbsolutePath ?? false;
                      if (!linkIsValid) {
                        _authLinkInpController.clear();
                        return showCustomSnackBar(
                            context, 'The link is not valid');
                      }
                      _verifyEmailLinkAndSignIn();
                    },
              label: const Text('Sign in with email link'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmailAuthLink() {
    final email = widget.email;
    sendSignInLinkToEmail(email).catchError((e) {
      print(e);
      showCustomSnackBar(context, 'Sending email failed');
    }).then((_) {
      showDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('An email has been sent to $email'),
            content: const Text(
                'Please copy the link that we sent to your email address. Remember NOT to click this link.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  FocusManager.instance.primaryFocus?.unfocus();

                  /// Open the URL in default browser and
                  /// exit app. Otherwise, the launched
                  /// browser exit along with your app.
                  launch(
                    'https://mail.google.com/mail',
                    forceSafariVC: false,
                  ).catchError((onError) {
                    print('Failed to open Gmail on iOS Safari. $onError');
                  });
                },
                child: Text(
                  'Okay',
                  style: TextStyle(color: Colors.blueGrey[700]!),
                ),
              )
            ],
          );
        },
      );
    });
  }

  Future<void> _verifyEmailLinkAndSignIn() async {
    final auth = FirebaseAuth.instance;
    final emailToAuthViaLink = widget.email;
    final authLinkSentToEmail = _authLinkInpController.text;
    if (!auth.isSignInWithEmailLink(authLinkSentToEmail)) {
      _authLinkInpController.clear();
      return showCustomSnackBar(context, 'The link is not valid');
    }

    try {
      // The client SDK will parse the code from the link for you.
      await auth.signInWithEmailLink(
          email: emailToAuthViaLink, emailLink: authLinkSentToEmail);
      print('Successfully signed in with email link!');
    } catch (onError) {
      String extraMsg = '';
      final error = onError as FirebaseAuthException;
      if (error.code == 'invalid-action-code')
        extraMsg =
            '. The link is incorrect, expired, or has already been used.';
      _authLinkInpController.clear();
      showCustomSnackBar(
          context, 'Cannot sign in with this email link$extraMsg');
    }
  }

  @override
  void dispose() {
    _authLinkInpController.dispose();
    super.dispose();
  }
}
