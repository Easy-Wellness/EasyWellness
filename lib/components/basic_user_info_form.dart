import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:users/components/custom_date_picker_form_field.dart';
import 'package:users/components/custom_picker_form_field.dart';
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

/// Info of the current user is automatically fetched and saved to Firestore
class BasicUserInfoForm extends StatefulWidget {
  BasicUserInfoForm({
    Key? key,
    required this.formKey,
    required this.onNameSaved,
    required this.onGenderSaved,
    required this.onBirthDateSaved,
    required this.onPhoneNumbSaved,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final void Function(String?) onNameSaved;
  final void Function(String?) onGenderSaved;
  final void Function(DateTime?) onBirthDateSaved;
  final void Function(String?) onPhoneNumbSaved;

  @override
  _BasicUserInfoFormState createState() => _BasicUserInfoFormState();
}

class _BasicUserInfoFormState extends State<BasicUserInfoForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _profileRef.get(),
        builder: (_, AsyncSnapshot<DocumentSnapshot<DbUserProfile>> snapshot) {
          if (snapshot.hasError) return Text('Unable to show your info');
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data!.data();
            return Form(
              key: widget.formKey,
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
                            onSaved: widget.onNameSaved,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                            onSaved: widget.onGenderSaved,
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
                            onSaved: widget.onBirthDateSaved,
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
                            onSaved: widget.onPhoneNumbSaved,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
          return const Center(child: CircularProgressIndicator.adaptive());
        },
      ),
    );
  }
}
