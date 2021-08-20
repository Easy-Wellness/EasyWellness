import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:users/components/clearable_text_form_field.dart';
import 'package:users/components/custom_date_picker_form_field.dart';
import 'package:users/components/custom_picker_form_field.dart';
import 'package:users/formatters/phone_input_formatter.dart';

final _fullnameRegex = RegExp(
  r"^[a-z àáâãèéêếìíòóôõùúăđĩũơưăạảấầẩẫậắằẳẵặẹẻẽềềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ,.'-]+$",
  unicode: true,
  caseSensitive: false,
);

class BasicUserInfoFormFields extends StatelessWidget {
  BasicUserInfoFormFields({
    Key? key,
    this.border,
    this.spacing = 8,
    this.initialName,
    this.initialGender,
    this.initialBirthDate,
    this.initialPhoneNumb,
    required this.onNameSaved,
    required this.onGenderSaved,
    required this.onBirthDateSaved,
    required this.onPhoneNumbSaved,
  }) : super(key: key);

  final double spacing;
  final InputBorder? border;
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
          ClearableTextFormField(
            initialValue: initialName,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Name is required';
              if (value.trim().length < 4 || value.trim().length > 64)
                return 'Name must contain between 4 and 64 characters';
              if (!_fullnameRegex.hasMatch(value))
                return 'Please remove invalid characters from your name';
            },
            onSaved: onNameSaved,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: border,
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
            decoration: InputDecoration(
              border: border,
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
            decoration: InputDecoration(
              border: border,
              labelText: 'Birth date',
              helperText: '',
            ),
            minimumYear:
                DateTime.now().subtract(const Duration(days: 36500)).year,
            maximumYear:
                DateTime.now().subtract(const Duration(days: 3650)).year,
          ),
          ClearableTextFormField(
            initialValue: initialPhoneNumb,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Phone number is required';
              if (value.length != 18)
                return 'Please enter a valid phone number';
            },
            onSaved: onPhoneNumbSaved,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.number,
            inputFormatters: [PhoneInputFormatter()],
            decoration: InputDecoration(
              border: border,
              labelText: 'Phone number',
              helperText: '',
            ),
          ),
        ].expand(
          (widget) => [
            widget,
            SizedBox(
              height: spacing,
            )
          ],
        )
      ],
    );
  }
}
