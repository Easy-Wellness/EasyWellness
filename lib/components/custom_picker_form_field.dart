import 'package:flutter/material.dart';

/// A Material picker that mimics the UI/UX design and behavior of the
/// iOS-style picker control [CupertinoPicker]. Used to
/// select an item in a short list
class CustomPickerFormField extends FormField<String> {
  CustomPickerFormField({
    Key? key,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    String? initialValue,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    TextStyle? style,
    bool enabled = true,
    this.resetIcon = const Icon(Icons.close),
    InputDecoration decoration = const InputDecoration(),
    required List<String> values,
    // Only properties with [this] belong to this class
    required this.itemAsString,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) {
            final _CustomPickerFormFieldState state =
                field as _CustomPickerFormFieldState;
            final InputDecoration effectiveDecoration = decoration
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return TextField(
              controller: state._controller,
              focusNode: state._focusNode,
              enabled: enabled,

              /// Disable content selection of [TextField]
              enableInteractiveSelection: false,
              showCursor: false,
              readOnly: true,
              decoration: effectiveDecoration.copyWith(
                errorText: field.errorText,
                suffixIcon: state.shouldShowClearIcon(effectiveDecoration)
                    ? IconButton(
                        icon: resetIcon,
                        onPressed: state.clear,
                      )
                    : null,
              ),
              style: style,
              onTap: () async {
                /// Unfocus to hide the focus highlight
                state._focusNode!.unfocus();
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

  final Icon resetIcon;
  final String Function(String) itemAsString;

  @override
  _CustomPickerFormFieldState createState() => _CustomPickerFormFieldState();
}

/// Manage the controller of [TextField]
class _CustomPickerFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  /// Retype type of widget from [FormField<String?>]
  /// to [CustomPickerFormField]
  @override
  CustomPickerFormField get widget => super.widget as CustomPickerFormField;

  bool get hasFocus => _focusNode!.hasFocus;
  bool get hasText => _controller!.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.itemAsString(widget.initialValue ?? ''));
    _focusNode = FocusNode();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    final friendlyString = widget.itemAsString(value ?? '');
    if (_controller!.text != friendlyString) _controller!.text = friendlyString;
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _focusNode?.dispose();
  }

  /// Invoked by the clear suffix icon to clear everything in the [FormField]
  void clear() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _controller!.clear();

      /// Close [ModalBottomSheet] because the clear suffix icon will open it
      Navigator.pop(context);
      didChange(null);
    });
  }

  bool shouldShowClearIcon([InputDecoration? decoration]) =>
      (hasText || hasFocus) &&
      _controller!.text.length > 0 &&
      decoration?.suffixIcon == null;
}
