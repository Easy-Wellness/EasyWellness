import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:users/components/basic_user_info_form_fields.dart';
import 'package:users/models/user_profile/db_user_profile.model.dart';
import 'package:users/utils/form_validation_manager.dart';

final _profileRef = FirebaseFirestore.instance
    .collection('user_profiles')
    .doc(FirebaseAuth.instance.currentUser!.uid)
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
  String? fullname;
  String? gender;
  DateTime? birthDate;
  String? phoneNumb;
  final formKey = GlobalKey<FormState>();
  final docSnapshot = _profileRef.get();

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
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
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
          child: Container(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder(
              future: docSnapshot,
              builder:
                  (_, AsyncSnapshot<DocumentSnapshot<DbUserProfile>> snapshot) {
                if (snapshot.hasError) return Text('Unable to show your info');
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data!.data();
                  return Form(
                    key: formKey,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: BasicUserInfoFormFields(
                          formValidationManager: FormValidationManager(),
                          initialName: data?.fullname,
                          initialGender: data?.gender,
                          initialBirthDate: data?.birthDate.toDate(),
                          initialPhoneNumb: data?.phoneNumber,
                          onNameSaved: (value) => fullname = value!.trim(),
                          onGenderSaved: (value) => gender = value,
                          onBirthDateSaved: (value) => birthDate = value,
                          onPhoneNumbSaved: (value) => phoneNumb = value,
                        ),
                      ),
                    ),
                  );
                }
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              },
            ),
          ),
        ),
      ),
    );
  }
}
