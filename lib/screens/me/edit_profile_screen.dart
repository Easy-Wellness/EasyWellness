import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:users/components/custom_date_picker_form_field.dart';
import 'package:users/components/custom_picker_form_field.dart';
import 'package:users/models/user_profile/db_user_profile.model.dart';

final db = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;
final profileRef = db
    .collection('user_profiles')
    .doc(auth.currentUser!.uid)
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
                  await profileRef
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
            child: FutureBuilder(
              future: profileRef.get(),
              builder:
                  (_, AsyncSnapshot<DocumentSnapshot<DbUserProfile>> snapshot) {
                if (snapshot.hasError) return Text('Unable to show your info');
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data!.data();
                  return Form(
                    key: _formKey,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...[
                                TextFormField(
                                  initialValue: data?.fullname,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty)
                                      return 'First name is required';
                                    if (value.length < 4 || value.length > 64)
                                      return 'Full name must contain between 4 and 64 characters';
                                  },
                                  onSaved: (value) => fullname = value!.trim(),
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: 'Full name',
                                    helperText: '',
                                  ),
                                ),
                                CustomPickerFormField(
                                  initialValue: data?.gender,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Gender is required';
                                  },
                                  onSaved: (value) => gender = value,
                                  values: const ['male', 'female', 'other'],
                                  valueAsString: (value) => value.titleCase,
                                  decoration: const InputDecoration(
                                    labelText: 'Gender',
                                    helperText: '',
                                  ),
                                ),
                                CustomDatePickerFormField(
                                  format: DateFormat.yMMMd(),
                                  validator: (value) {
                                    if (value == null)
                                      return 'Birth date is required';
                                  },
                                  onSaved: (value) => birthDate = value,
                                  decoration: const InputDecoration(
                                    labelText: 'Birth date',
                                    helperText: '',
                                  ),
                                  initialDateTime: data?.birthDate.toDate(),
                                  minimumYear: DateTime.now()
                                      .subtract(const Duration(days: 36500))
                                      .year,
                                  maximumYear: DateTime.now()
                                      .subtract(const Duration(days: 3650))
                                      .year,
                                ),
                                TextFormField(
                                  initialValue: data?.phoneNumber,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Phone number is required';
                                    if (value.length < 9)
                                      return 'Phone number is not valid';
                                  },
                                  onSaved: (value) => phoneNumb = value,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    labelText: 'Phone number',
                                    helperText: '',
                                  ),
                                ),
                              ].expand(
                                (widget) => [
                                  widget,
                                  const SizedBox(
                                    height: 4,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator.adaptive());
              },
            ),
          ),
        ),
      ),
    );
  }
}
