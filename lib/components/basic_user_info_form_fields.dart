import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:users/components/custom_date_picker_form_field.dart';
import 'package:users/components/custom_picker_form_field.dart';
class BasicUserInfoFormFields extends StatelessWidget {
  BasicUserInfoFormFields({
    Key? key,
    this.initialName,
    this.initialGender,
    this.initialBirthDate,
    this.initialPhoneNumb,
    required this.onNameSaved,
    required this.onGenderSaved,
    required this.onBirthDateSaved,
    required this.onPhoneNumbSaved,
  }) : super(key: key);

  final String? initialName;
  final String? initialGender;
  final DateTime? initialBirthDate;
  final String? initialPhoneNumb;
  final void Function(String?) onNameSaved;
  final void Function(String?) onGenderSaved;
  final void Function(DateTime?) onBirthDateSaved;
  final void Function(String?) onPhoneNumbSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...[
          TextFormField(
            initialValue: initialName,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'First name is required';
              if (value.length < 4 || value.length > 64)
                return 'Full name must contain between 4 and 64 characters';
            },
            onSaved: onNameSaved,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: 'Full name',
              helperText: '',
            ),
          ),
          CustomPickerFormField(
            initialValue: initialGender,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Gender is required';
            },
            onSaved: onGenderSaved,
            values: const ['male', 'female', 'other'],
            valueAsString: (value) => value.titleCase,
            decoration: const InputDecoration(
              labelText: 'Gender',
              helperText: '',
            ),
          ),
          CustomDatePickerFormField(
            initialDateTime: initialBirthDate,
            format: DateFormat.yMMMd(),
            validator: (value) {
              if (value == null) return 'Birth date is required';
            },
            onSaved: onBirthDateSaved,
            decoration: const InputDecoration(
              labelText: 'Birth date',
              helperText: '',
            ),
            minimumYear:
                DateTime.now().subtract(const Duration(days: 36500)).year,
            maximumYear:
                DateTime.now().subtract(const Duration(days: 3650)).year,
          ),
          TextFormField(
            initialValue: initialPhoneNumb,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Phone number is required';
              if (value.length < 9) return 'Phone number is not valid';
            },
            onSaved: onPhoneNumbSaved,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
    );
  }
}
