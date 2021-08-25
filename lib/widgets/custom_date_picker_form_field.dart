import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A Material [TextFormField] that receives a chosen date from
/// an iOS-style [CupertinoDatePicker]
class CustomDatePickerFormField extends FormField<DateTime> {
  CustomDatePickerFormField({
    // Features
    required this.format,
    this.resetIcon = const Icon(Icons.close),

    // From [super]
    Key? key,
    FormFieldSetter<DateTime>? onSaved,
    FormFieldValidator<DateTime>? validator,
    DateTime? initialDateTime,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    bool enabled = true,

    // From [TextField]
    // Key? key,
    // bool enabled = true,
    InputDecoration decoration = const InputDecoration(),
    TextStyle? style,

    // From [CupertinoDatePicker]
    // DateTime? initialDateTime
    DateTime? minimumDate,
    required int minimumYear,
    DateTime? maximumDate,
    required int maximumYear,
    Color? backgroundColor,
  }) : super(
          key: key,
          initialValue: initialDateTime,
          onSaved: onSaved,
          validator: validator,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (field) {
            final _CustomDatePickerFormFieldState state =
                field as _CustomDatePickerFormFieldState;
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
                state._focusNode!.unfocus();
                showModalBottomSheet<DateTime>(
                  context: field.context,
                  builder: (_) {
                    final defaultDateTime = field.value ??
                        initialDateTime ??
                        DateTime.utc(maximumYear);
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      if (field.value == null) field.didChange(defaultDateTime);
                    });
                    return SizedBox(
                      height: 300,
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
                            child: CupertinoTheme(
                              data: CupertinoThemeData(
                                textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(
                                    fontSize: 21,
                                    color: Theme.of(field.context).accentColor,
                                  ),
                                ),
                              ),
                              child: CupertinoDatePicker(
                                backgroundColor: backgroundColor,
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: defaultDateTime,
                                minimumDate: minimumDate,
                                minimumYear: minimumYear,
                                maximumDate: maximumDate,
                                maximumYear: maximumYear,
                                onDateTimeChanged: (date) =>
                                    field.didChange(date),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;
  final Icon resetIcon;

  @override
  _CustomDatePickerFormFieldState createState() =>
      _CustomDatePickerFormFieldState();

  /// Returns an empty string if [DateFormat.format()] throws or [date] is null.
  static String tryFormat(DateTime? date, DateFormat format) {
    if (date != null) {
      try {
        return format.format(date);
      } catch (e) {
        print('Error formatting date: $e');
      }
    }
    return '';
  }
}

class _CustomDatePickerFormFieldState extends FormFieldState<DateTime> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  bool tapable = true;

  bool get hasFocus => _focusNode!.hasFocus;
  bool get hasText => _controller!.text.isNotEmpty;

  @override
  CustomDatePickerFormField get widget =>
      super.widget as CustomDatePickerFormField;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: format(widget.initialValue));
    _focusNode = FocusNode();
  }

  @override
  void didChange(DateTime? value) {
    super.didChange(value);
    _controller!.text = format(value);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _focusNode?.dispose();
  }

  String format(DateTime? date) =>
      CustomDatePickerFormField.tryFormat(date, widget.format);

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
