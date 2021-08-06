import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:users/components/custom_date_time_form_field.dart';
import 'package:users/components/custom_picker_form_field.dart';

final db = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;
final profileRef = db.collection('user_profiles').doc(auth.currentUser!.uid);

class ManageAccountScreen extends StatefulWidget {
  static const String routeName = '/manage_account';

  @override
  _ManageAccountScreenState createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
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
                  await profileRef.set({
                    'fullname': fullname,
                    'gender': gender,
                    'birth_date': Timestamp.fromDate(birthDate!),
                    'phone_number': phoneNumb,
                  }, SetOptions(merge: true)).catchError(
                      (err) => print("Failed to upsert user profile: $err"));
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
              builder: (_, snapshot) {
                if (snapshot.hasError) return Text('Unable to show your info');
                return Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...[
                              TextFormField(
                                initialValue: fullname,
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
                                initialValue: gender,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Gender is required';
                                },
                                onSaved: (value) => gender = value,
                                values: const ['male', 'female', 'other'],
                                itemAsString: (value) => value.titleCase,
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  helperText: '',
                                ),
                              ),
                              CustomDateTimeFormField(
                                initialValue: birthDate,
                                validator: (value) {
                                  if (value == null)
                                    return 'Birth date is required';
                                },
                                onSaved: (value) => birthDate = value,
                                decoration: const InputDecoration(
                                  labelText: 'Birth date',
                                  helperText: '',
                                ),
                                format: DateFormat.yMMMMEEEEd(),
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                    context: context,
                                    helpText: 'SWIPE UP OR DOWN, LEFT OR RIGHT',
                                    cancelText: 'CLOSE',
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    initialDatePickerMode: DatePickerMode.year,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 36500)),
                                    initialDate: DateTime.now()
                                        .subtract(const Duration(days: 3650)),
                                    lastDate: DateTime.now()
                                        .subtract(const Duration(days: 3650)),
                                  );
                                },
                              ),
                              TextFormField(
                                initialValue: phoneNumb,
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
              },
            ),
          ),
        ),
      ),
    );
  }
}
