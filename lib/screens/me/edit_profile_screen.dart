import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:users/components/basic_user_info_form.dart';
import 'package:users/models/user_profile/db_user_profile.model.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final _profileRef = _db
    .collection('user_profiles')
    .doc(_auth.currentUser!.uid)
    .withConverter<DbUserProfile>(
      fromFirestore: (snapshot, _) => DbUserProfile.fromJson(snapshot.data()!),
      toFirestore: (profile, _) => profile.toJson(),
    );

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit_profile';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? fullname;
  String? gender;
  DateTime? birthDate;
  String? phoneNumb;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit personal info'),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await _profileRef
                      .set(
                        DbUserProfile(
                          fullname: fullname!,
                          gender: gender!,
                          birthDate: Timestamp.fromDate(birthDate!),
                          phoneNumber: phoneNumb!,
                        ),
                        SetOptions(merge: true),
                      )
                      .catchError((err) =>
                          print("Failed to upsert user profile: $err"));
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                textStyle: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: BasicUserInfoForm(
            formKey: _formKey,
            onNameSaved: (value) => fullname = value!.trim(),
            onGenderSaved: (value) => gender = value,
            onBirthDateSaved: (value) => birthDate = value,
            onPhoneNumbSaved: (value) => phoneNumb = value,
          ),
        ),
      ),
    );
  }
}
