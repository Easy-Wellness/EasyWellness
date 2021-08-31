import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users/models/appointment/db_appointment.model.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/models/user_profile/db_user_profile.model.dart';
import 'package:users/routes.dart';
import 'package:users/utils/form_validation_manager.dart';
import 'package:users/utils/navigate_to_root_screen.dart';
import 'package:users/utils/show_custom_snack_bar.dart';
import 'package:users/widgets/basic_user_info_form_fields.dart';
import 'package:users/widgets/booking_summary.dart';

final _profileRef = FirebaseFirestore.instance
    .collection('user_profiles')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .withConverter<DbUserProfile>(
      fromFirestore: (snapshot, _) => DbUserProfile.fromJson(snapshot.data()!),
      toFirestore: (profile, _) => profile.toJson(),
    );

class CreateBookingScreen extends StatelessWidget {
  static const String routeName = '/create_booking';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Your booking summary',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        body: SafeArea(child: Body()),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final formKey = GlobalKey<FormState>();
  final formValidationManager = FormValidationManager();
  final profileSnapshot = _profileRef.get();
  String fullname = '';
  String gender = '';
  DateTime birthDate = DateTime.now();
  String phoneNumb = '';
  String? visitReason;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final bookedService = args['bookedService'] as DbNearbyService;
    final serviceId = args['serviceId'] as String;
    final selectedDateTime = args['selectedDateTime'] as DateTime;

    return Center(
      child: FutureBuilder(
        future: profileSnapshot,
        builder: (_, AsyncSnapshot<DocumentSnapshot<DbUserProfile>> snapshot) {
          if (snapshot.hasError) return Text('Unable to show your info');
          if (snapshot.connectionState == ConnectionState.done) {
            final data = snapshot.data!.data();
            return Form(
              key: formKey,
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookingSummary(
                          serviceName: bookedService.serviceName,
                          placeName: bookedService.placeName,
                          address: bookedService.address,
                          dateTime: selectedDateTime,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Divider(thickness: 2),
                        ),
                        Text('Contact Info',
                            style: Theme.of(context).textTheme.headline6),
                        const SizedBox(height: 8),
                        Text(
                          'The form below is prefilled with the info from your previous booking',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        const SizedBox(height: 24),
                        BasicUserInfoFormFields(
                          formValidationManager: formValidationManager,
                          spacing: 16,
                          border: const OutlineInputBorder(),
                          initialName: data?.fullname,
                          initialGender: data?.gender,
                          initialBirthDate: data?.birthDate.toDate(),
                          initialPhoneNumb: data?.phoneNumber,
                          onNameSaved: (value) => fullname = value!.trim(),
                          onGenderSaved: (value) => gender = value!,
                          onBirthDateSaved: (value) => birthDate = value!,
                          onPhoneNumbSaved: (value) => phoneNumb = value!,
                        ),
                        const SizedBox(height: 4),
                        AbsorbPointer(
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: 'Email',
                                hintText:
                                    FirebaseAuth.instance.currentUser!.email,
                                helperText:
                                    'This is the current email associated with your account'),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          onSaved: (value) => visitReason = value?.trim(),
                          decoration: const InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Reason for visit',
                            alignLabelWithHint: true,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'Describe your symptoms (optional)',
                            helperText: '',
                          ),
                          minLines: 5,
                          maxLines: 5,
                          maxLength: 300,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                final userProfile = DbUserProfile(
                                  fullname: fullname,
                                  gender: gender,
                                  birthDate: Timestamp.fromDate(birthDate),
                                  phoneNumber: phoneNumb,
                                );
                                final FutureOr future1 = _createAppointment(
                                  accountId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  serviceId: serviceId,
                                  service: bookedService,
                                  dateTime: selectedDateTime,
                                  visitReason: visitReason,
                                  userProfile: userProfile,
                                );
                                final FutureOr future2 = _profileRef.set(
                                  DbUserProfile(
                                    fullname: fullname,
                                    gender: gender,
                                    birthDate: Timestamp.fromDate(birthDate),
                                    phoneNumber: phoneNumb,
                                  ),
                                  SetOptions(merge: true),
                                );
                                await future1;
                                await future2;
                                showCustomSnackBar(context,
                                    'Your appointment is successfully scheduled');
                                navigateToRootScreen(
                                    context, RootScreen.appointmentListScreen);
                              } else
                                formValidationManager
                                    .erroredFields.first.focusNode
                                    .requestFocus();
                            },
                            child: Text('Reserve'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const CircularProgressIndicator.adaptive();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    formValidationManager.dispose();
  }
}

FutureOr<DocumentReference<DbAppointment>> _createAppointment({
  required String accountId,
  required String serviceId,
  required DbNearbyService service,
  required DateTime dateTime,
  required DbUserProfile userProfile,
  required String? visitReason,
}) {
  final apptsRef = FirebaseFirestore.instance
      .collection('places')
      .doc(service.placeId)
      .collection('appointments')
      .withConverter<DbAppointment>(
        fromFirestore: (snapshot, _) =>
            DbAppointment.fromJson(snapshot.data()!),
        toFirestore: (appt, _) => appt.toJson(),
      );
  return apptsRef.add(DbAppointment(
    accountId: accountId,
    placeId: service.placeId,
    placeName: service.placeName,
    serviceId: serviceId,
    serviceName: service.serviceName,
    address: service.address,
    userProfile: userProfile,
    visitReason: visitReason,
    status: ApptStatus.confirmed,
    createdAt: Timestamp.now(),
    effectiveAt: Timestamp.fromDate(dateTime),
  ));
}
