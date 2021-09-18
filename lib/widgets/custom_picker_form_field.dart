import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A Material [TextFormField] that receives a chosen value from an iOS-style
/// [CupertinoPicker].
class CustomPickerFormField extends FormField<String> {
  CustomPickerFormField({
    // Features
    this.resetIcon = const Icon(Icons.close),
    // Only properties with [this] belong to this class
    required this.values,
    required this.valueAsString,

    // From [super]
    Key? key,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    String? initialValue,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    bool enabled = true,

    // From [TextField]
    // Key? key,
    // String? initialValue,
    // bool enabled = true,
    InputDecoration decoration = const InputDecoration(),
    TextStyle? style,
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
                        onPressed: () {
                          // Disable onTap() handler
                          state.setTapable(false);
                          state.clear();
                        },
                      )
                    : null,
              ),
              style: style,
              onTap: () {
                if (!state.tapable) {
                  state.setTapable(true);
                  return;
                }
                // Unfocus to hide the focus highlight
                state._focusNode!.unfocus();
                showModalBottomSheet<String>(
                  context: field.context,
                  builder: (_) {
                    /// The cb below only runs when the modal pops up and
                    /// [ListWheelScrollView] backing [CupertinoPicker] has
                    /// finished rendering (build method is complete)
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      state._scrollWheelController?.jumpToItem(
                        field.value == null ? 0 : values.indexOf(field.value!),
                      );
                      if (field.value == null) field.didChange(values[0]);
                    });
                    return SizedBox(
                      height: values.length >= 6 ? 300 : 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextButton(
                              onPressed: () => Navigator.pop(field.context),
                              child: Text('Done'),
                            ),
                          ),
                          const Divider(thickness: 1),
                          Expanded(
                            child: CupertinoPicker.builder(
                              /// if [itemExtent] is too low, the content for each
                              /// item will be squished together
                              itemExtent: 32,
                              scrollController: state._scrollWheelController,
                              onSelectedItemChanged: (index) =>
                                  field.didChange(values[index]),
                              childCount: values.length,
                              itemBuilder: (_, index) => Center(
                                child: Text(
                                  valueAsString(values[index]),
                                  style: TextStyle(
                                    color: Theme.of(field.context)
                                        .colorScheme
                                        .secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );

  final Icon resetIcon;
  final List<String> values;
  final String Function(String) valueAsString;

  @override
  _CustomPickerFormFieldState createState() => _CustomPickerFormFieldState();
}

class _CustomPickerFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  FixedExtentScrollController? _scrollWheelController;
  bool tapable = true;

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
        text: widget.valueAsString(widget.initialValue ?? ''));
    _focusNode = FocusNode();
    _scrollWheelController = FixedExtentScrollController(
      initialItem: this.value == null ? 0 : widget.values.indexOf(this.value!),
    );
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    final friendlyString = widget.valueAsString(value ?? '');
    if (_controller!.text != friendlyString) _controller!.text = friendlyString;
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _focusNode?.dispose();
    _scrollWheelController?.dispose();
  }

  void setTapable(bool b) => setState(() => tapable = b);

  /// Invoked by the clear suffix icon to clear everything in the [FormField]
  void clear() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _controller!.clear();
      didChange(null);
    });
  }

  bool shouldShowClearIcon([InputDecoration? decoration]) =>
      (hasText || hasFocus) &&
      _controller!.text.length > 0 &&
      decoration?.suffixIcon == null;
}
