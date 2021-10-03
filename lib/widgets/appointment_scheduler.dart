import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/place/weekly_schedule.model.dart';
import 'package:users/utils/get_times_in_secs_from_range.dart';
import 'package:users/utils/seconds_to_friendly_time.dart';
import 'package:users/utils/show_custom_snack_bar.dart';

/// Validate if the DateTime is bookable, the client might need to send an
/// HTTP request to ask the server for this information
typedef AppointmentTimeValidator = Future<String?> Function(DateTime);

class AppointmentScheduler extends StatefulWidget {
  const AppointmentScheduler({
    Key? key,
    required this.weeklySchedule,
    required this.minuteIncrements,
    required this.minLeadHours,
    required this.maxLeadDays,
    required this.validator,
    required this.onTimeSlotSelect,
  }) : super(key: key);

  final WeeklySchedule weeklySchedule;
  final int minuteIncrements;
  final int minLeadHours;
  final int maxLeadDays;

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
      lastDate: DateTime.now().add(Duration(days: widget.maxLeadDays)),
    );
    setSelectedDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final String dayOfWeek =
        DateFormat('EEEE').format(selectedDate).toLowerCase();
    final intervalListForSelectedDay =
        (widget.weeklySchedule.toJson()[dayOfWeek] as List)
            .map<TimeIntervalInSecs>(
                (interval) => TimeIntervalInSecs.fromJson(interval))
            .toList();
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
          intervalList: intervalListForSelectedDay,
          minuteIncrements: widget.minuteIncrements,
          minLeadHours: widget.minLeadHours,
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
    required this.intervalList,
    required this.minuteIncrements,
    required this.minLeadHours,
    required this.onAnotherDateSelect,
    required this.validator,
    required this.onTimeSlotSelect,
  }) : super(key: key);

  final DateTime selectedDate;
  final List<TimeIntervalInSecs> intervalList;
  final int minuteIncrements;
  final int minLeadHours;
  final void Function(DateTime? date) onAnotherDateSelect;
  final AppointmentTimeValidator validator;
  final ValueSetter<DateTime> onTimeSlotSelect;

  @override
  Widget build(BuildContext context) {
    final dayPartPanels = _buildDayPartPanels(
      selectedDate: selectedDate,
      intervalList: intervalList,
      minuteIncrements: minuteIncrements,
      minLeadHours: minLeadHours,
      validator: validator,
      onTimeSlotSelect: onTimeSlotSelect,
    );
    return dayPartPanels.isEmpty
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
  required DateTime selectedDate,
  required List<TimeIntervalInSecs> intervalList,
  required int minuteIncrements,
  required int minLeadHours,
  required AppointmentTimeValidator validator,
  required ValueSetter<DateTime> onTimeSlotSelect,
}) {
  final List<int> timesInAday = [];
  final List<int> earlyMorningTimes = [];
  final List<int> morningTimes = [];
  final List<int> afternoonTimes = [];
  final List<int> eveningTimes = [];
  intervalList.forEach(
    (interval) => timesInAday.addAll(getTimesInSecsFromRange(
      interval.start,
      interval.end,
      minuteIncrements * 60,
    )),
  );
  timesInAday.sort();
  timesInAday.forEach((time) {
    final timeIsBookable = DateTime.now()
            .add(Duration(minutes: 10 + minLeadHours * 60))
            .compareTo(selectedDate.add(Duration(seconds: time))) <=
        0;
    if (0 <= time && time <= 20700 && timeIsBookable)
      return earlyMorningTimes.add(time);
    if (21600 <= time && time <= 42300 && timeIsBookable)
      return morningTimes.add(time);
    if (43200 <= time && time <= 63900 && timeIsBookable)
      return afternoonTimes.add(time);
    if (64800 <= time && time <= 85500 && timeIsBookable)
      return eveningTimes.add(time);
  });
  return [
    if (earlyMorningTimes.isNotEmpty)
      _buildPanelForTimeSlots(
        headerText: 'Early Morning (from Midnight to 5:45 AM)',
        selectedDate: selectedDate,
        times: earlyMorningTimes,
        validator: validator,
        onTimeSlotSelect: onTimeSlotSelect,
      ),
    if (morningTimes.isNotEmpty)
      _buildPanelForTimeSlots(
        headerText: 'Morning (from 6AM to 11:45 AM)',
        selectedDate: selectedDate,
        times: morningTimes,
        validator: validator,
        onTimeSlotSelect: onTimeSlotSelect,
      ),
    if (afternoonTimes.isNotEmpty)
      _buildPanelForTimeSlots(
        headerText: 'Afternoon (from 12PM to 5:45 PM)',
        selectedDate: selectedDate,
        times: afternoonTimes,
        validator: validator,
        onTimeSlotSelect: onTimeSlotSelect,
      ),
    if (eveningTimes.isNotEmpty)
      _buildPanelForTimeSlots(
        headerText: 'Evening (from 6PM to 11:45 PM)',
        selectedDate: selectedDate,
        times: eveningTimes,
        validator: validator,
        onTimeSlotSelect: onTimeSlotSelect,
      )
  ];
}

ExpansionPanelRadio _buildPanelForTimeSlots({
  required String headerText,
  required DateTime selectedDate,
  required List<int> times,
  required AppointmentTimeValidator validator,
  required ValueSetter<DateTime> onTimeSlotSelect,
}) {
  if (times.isEmpty)
    throw ArgumentError(
        'Time must be provided to the panel that shows time(s) within a part of a day');
  return ExpansionPanelRadio(
    value: headerText,
    canTapOnHeader: true,
    headerBuilder: (context, isOpen) => ListTile(
      title: Text(
        headerText,
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
        for (final time in times)
          Builder(builder: (context) {
            return OutlinedButton(
              onPressed: () async {
                final bookedDateTime =
                    selectedDate.add(Duration(seconds: time));
                final errorMsg = await validator(bookedDateTime);
                if (errorMsg != null) {
                  showCustomSnackBar(context, errorMsg);
                  return;
                }
                onTimeSlotSelect(bookedDateTime);
              },
              child: Text(secondsToFriendlyTime(time)),
            );
          })
      ],
    ),
  );
}
