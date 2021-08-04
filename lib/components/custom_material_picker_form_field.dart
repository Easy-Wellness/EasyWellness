import 'package:flutter/material.dart';

/// Mimic the UI/UX design and behavior of the
/// iOS-style picker control [CupertinoPicker]. Used to
/// select an item in a short list
class CustomMaterialPickerFormField extends FormField<String> {
  CustomMaterialPickerFormField({
    Key? key,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    String? initialValue,
    AutovalidateMode? autovalidateMode,
    TextStyle? style,
    bool? enabled,
    InputDecoration? decoration,
    required List<String> values,
    // Only properties with [this] belong to this class
    required this.itemAsString,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          enabled: enabled ?? decoration?.enabled ?? true,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.always,
          builder: (FormFieldState<String> field) {
            final _CustomMaterialPickerFormFieldState state =
                field as _CustomMaterialPickerFormFieldState;
            return TextField(
              controller: state._controller,
              enabled: enabled ?? decoration?.enabled ?? true,

              /// Disable content selection of [TextField]
              enableInteractiveSelection: false,
              showCursor: false,
              readOnly: true,
              decoration: (decoration ?? const InputDecoration())
                  .copyWith(errorText: field.errorText),
              style: style,
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: field.context,
                  builder: (_) => SafeArea(
                    child: Container(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: values
                            .map((value) => TextButton(
                                  onPressed: () => Navigator.pop<String>(
                                      field.context, value),
                                  child: Text(itemAsString(value)),
                                  style: value == field.value
                                      ? TextButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(field.context)
                                                  .accentColor
                                                  .withOpacity(0.2),
                                        )
                                      : null,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                );
                if (selected != null) field.didChange(selected);
              },
            );
          },
        );

  final String Function(String) itemAsString;

  @override
  _CustomMaterialPickerFormFieldState createState() =>
      _CustomMaterialPickerFormFieldState();
}

/// Manage the controller of [TextField]
class _CustomMaterialPickerFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  /// Retype type of widget from [FormField<String?>]
  /// to [CustomMaterialPickerFormField]
  @override
  CustomMaterialPickerFormField get widget =>
      super.widget as CustomMaterialPickerFormField;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.itemAsString(widget.initialValue ?? ''));
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    final friendlyString = widget.itemAsString(value ?? '');
    if (_controller!.text != friendlyString) _controller!.text = friendlyString;
  }

  @override
  void reset() {
    super.reset();
    _controller!.text = widget.itemAsString(widget.initialValue ?? '');
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
}
