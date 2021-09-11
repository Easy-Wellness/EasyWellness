import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/constants/misc.dart';
import 'package:users/models/appointment/opening_hours.model.dart';
import 'package:users/utils/get_times_in_secs_from_range.dart';
import 'package:users/utils/seconds_to_time.dart';
import 'package:users/utils/show_custom_snack_bar.dart';

/// Validate if the DateTime is bookable, the client might need to send an
/// HTTP request to ask the server for this information
typedef AppointmentTimeValidator = Future<String?> Function(DateTime);

class AppointmentScheduler extends StatefulWidget {
  const AppointmentScheduler({
    Key? key,
    required this.validator,
    required this.onTimeSlotSelect,
  }) : super(key: key);

  /// A method that validates the DateTime selected by the user. Returns an
  /// error string to display if the DateTime is unbookable, or null otherwise.
  /// [onTimeSlotSelect] is invoked if and only if the selected date time
  /// passes the [validator] check
  final AppointmentTimeValidator validator;
  final ValueSetter<DateTime> onTimeSlotSelect;

  @override
  _AppointmentSchedulerState createState() => _AppointmentSchedulerState();
}

class _AppointmentSchedulerState extends State<AppointmentScheduler> {
  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());

  void setSelectedDate(DateTime? date) {
    if (date != null && date != selectedDate)
      setState(() => selectedDate = date);
  }

  Future<void> selectDate(BuildContext context) async {
    /// The returned DateTime contains only the date part, the time part is
    /// ignored and always set to midnight T00:00:00.000
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'SWIPE LEFT OR RIGHT TO CHANGE MONTH',
      cancelText: 'CLOSE',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 150)),
    );
    setSelectedDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: TextButton.icon(
            onPressed: () => selectDate(context),
            icon: const Icon(Icons.today),
            label: Text(DateFormat.yMMMMEEEEd().format(selectedDate)),
          ),
        ),
        const SizedBox(height: 16),

        /// Must drop a unique key here or
        /// an unknown weird error will be thown (I don't know why)
        DayPartPanelList(
          key: UniqueKey(),
          selectedDate: selectedDate,
          onAnotherDateSelect: setSelectedDate,
          validator: widget.validator,
          onTimeSlotSelect: widget.onTimeSlotSelect,
        ),
      ],
    );
  }
}

class DayPartPanelList extends StatelessWidget {
  const DayPartPanelList({
    Key? key,
    required this.selectedDate,
    required this.onAnotherDateSelect,
    required this.validator,
    required this.onTimeSlotSelect,
  }) : super(key: key);

  final DateTime selectedDate;
  final void Function(DateTime? date) onAnotherDateSelect;
  final AppointmentTimeValidator validator;
  final ValueSetter<DateTime> onTimeSlotSelect;

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat('EEEE').format(selectedDate).toLowerCase();

    /// There are at most 4 different objects in the list below, each one is
    /// mapped to a different part of the day
    final openingHoursForSelectedDate = OpeningHours.fromJson(apptTimesInSecs)
        .hours
        .toJson()[dayOfWeek] as List<OpenCloseTimesInSecs>;
    final dayPartPanels = _buildDayPartPanels(
      context: context,
      selectedDate: selectedDate,
      openingHoursInSecs: openingHoursForSelectedDate,
      validator: validator,
      onTimeSlotSelect: onTimeSlotSelect,
    );
    return dayPartPanels.length == 0
        ? Column(
            children: [
              Text(
                'Oops, there are no hours available for this day',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              const SizedBox(height: 8),
              Text(
                'Please select another day',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => onAnotherDateSelect(
                    selectedDate.add(const Duration(days: 1))),
                child: Text('Select another day'),
              ),
            ],
          )
        : ExpansionPanelList.radio(
            animationDuration: const Duration(milliseconds: 800),
            children: dayPartPanels,
          );
  }
}

List<ExpansionPanelRadio> _buildDayPartPanels({
  required BuildContext context,
  required DateTime selectedDate,
  required List<OpenCloseTimesInSecs> openingHoursInSecs,
  required AppointmentTimeValidator validator,
  required ValueSetter<DateTime> onTimeSlotSelect,
}) {
  final List<ExpansionPanelRadio> panelRadios = [];

  openingHoursInSecs.forEach((rangeInSecs) {
    final currentDateTime = DateTime.now();
    // Get a list of times based on an interval of 30 minutes to build
    // the time slots for this [DayPartPanel].
    final timesInSecs =
        getTimesInSecsFromRange(rangeInSecs.open, rangeInSecs.close);
    const minLeadTime = Duration(minutes: 30);
    // The time it takes the user to explore the service and
    // then finally decide to book it.
    const exploreTime = Duration(minutes: 10);
    if (selectedDate
        .add(Duration(seconds: timesInSecs[timesInSecs.length - 1]))
        .isBefore(currentDateTime.add(minLeadTime + exploreTime))) return;
    String header = '';
    if (0 <= rangeInSecs.open && rangeInSecs.close <= 20700)
      header = 'Early Morning (from Midnight to 5:45 AM)';
    if (21600 <= rangeInSecs.open && rangeInSecs.close <= 42300)
      header = 'Morning (from 6AM to 11:45 AM)';
    if (43200 <= rangeInSecs.open && rangeInSecs.close <= 63900)
      header = 'Afternoon (from 12PM to 5:45 PM)';
    if (64800 <= rangeInSecs.open && rangeInSecs.close <= 85500)
      header = 'Evening (from 6PM to 11:45 PM)';
    panelRadios.add(ExpansionPanelRadio(
      value: header,
      canTapOnHeader: true,
      headerBuilder: (context, isOpen) => ListTile(
        title: Text(
          header,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: 3,
        padding: const EdgeInsets.all(8),
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          for (int timeInSecs in timesInSecs)
            if (currentDateTime.add(exploreTime + minLeadTime).compareTo(
                    selectedDate.add(Duration(seconds: timeInSecs))) <=
                0)
              OutlinedButton(
                onPressed: () async {
                  final bookedDateTime =
                      selectedDate.add(Duration(seconds: timeInSecs));
                  final errorMsg = await validator(bookedDateTime);
                  if (errorMsg != null) {
                    showCustomSnackBar(context, errorMsg);
                    // Don't invoke the [onTimeSlotSelect] method
                    return;
                  }
                  onTimeSlotSelect(bookedDateTime);
                },
                child: Text(secondsToFriendlyTime(timeInSecs)),
              )
        ],
      ),
    ));
  });
  return panelRadios;
}
