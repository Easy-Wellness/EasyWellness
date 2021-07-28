import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/booking/opening_hours.model.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/screens/home/create_booking_screen.dart';
import 'package:users/utils/get_times_in_secs_from_range.dart';
import 'package:users/utils/seconds_to_time.dart';

class ScheduleBookingScreen extends StatelessWidget {
  static const String routeName = '/schedule_booking';

  @override
  Widget build(BuildContext context) {
    final service = (ModalRoute.of(context)!.settings.arguments
        as Map<String, Object>)['service'] as DbNearbyService;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            service.placeName,
            style: const TextStyle(fontSize: 16),
          ),
          bottom: TabBar(
            unselectedLabelColor: Theme.of(context).hintColor,
            labelColor: Theme.of(context).accentColor,
            tabs: [
              Tab(text: 'schedule'.toUpperCase()),
              Tab(text: 'overview'.toUpperCase()),
            ],
          ),
        ),
        body: TabBarView(children: [ScheduleTabView(), Container()]),
      ),
    );
  }
}

class ScheduleTabView extends StatefulWidget {
  @override
  _ScheduleTabViewState createState() => _ScheduleTabViewState();
}

class _ScheduleTabViewState extends State<ScheduleTabView> {
  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());

  Future<void> _selectDate(BuildContext context) async {
    /// The returned DateTime contains only the date part, the time part is
    /// ignored and always set to midnight T00:00:00.000
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 150)),
    );
    if (picked != null && picked != selectedDate)
      setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: TextButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.today),
              label: Text(DateFormat.yMMMMEEEEd().format(selectedDate)),
            ),
          ),
          const SizedBox(height: 16),
          TimeSlotSelector(selectedDate: selectedDate),
        ],
      ),
    );
  }
}

class TimeSlotSelector extends StatefulWidget {
  const TimeSlotSelector({Key? key, required this.selectedDate})
      : super(key: key);

  final DateTime selectedDate;

  @override
  TimeSlotSelectorState createState() => TimeSlotSelectorState();
}

class TimeSlotSelectorState extends State<TimeSlotSelector> {
  /// Maintain a list of which panels are opened
  int? currentOpenPanel;
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      animationDuration: const Duration(milliseconds: 800),
      expandedHeaderPadding: const EdgeInsets.all(8),
      children: generateTimeSlotPanels(context, widget.selectedDate),
    );
  }
}

List<ExpansionPanelRadio> generateTimeSlotPanels(
    BuildContext context, DateTime selectedDate) {
  /// There are at most 4 different objects in this list, each one is
  /// mapped to a different part of the day
  final openingHoursInSecs = OpeningHours.fromJson(apptTimes)
          .hours
          .toJson()[DateFormat('EEEE').format(selectedDate).toLowerCase()]
      as List<OpenCloseTimesInSecs>;
  return openingHoursInSecs.map<ExpansionPanelRadio>((timesInSecs) {
    String header = '';
    if (0 <= timesInSecs.open && timesInSecs.close <= 20700)
      header = 'Early Morning (from Midnight to 5:45 AM)';
    if (21600 <= timesInSecs.open && timesInSecs.close <= 42300)
      header = 'Morning (from 6AM to 11:45 AM)';
    if (43200 <= timesInSecs.open && timesInSecs.close <= 63900)
      header = 'Afternoon (from 12PM to 5:45 PM)';
    if (64800 <= timesInSecs.open && timesInSecs.close <= 85500)
      header = 'Evening (from 6PM to 11:45 PM)';
    return ExpansionPanelRadio(
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
        children: getTimesInSecsFromRange(timesInSecs.open, timesInSecs.close)
            .map((timeInSecs) => OutlinedButton(
                  onPressed: () => Navigator.pushNamed(
                      context, CreateBookingScreen.routeName,
                      arguments: {
                        'selecteDateTime':
                            selectedDate.add(Duration(seconds: timeInSecs)),
                      }),
                  child: Text(secondsToTime(timeInSecs)),
                ))
            .toList(),
      ),
    );
  }).toList(growable: false);
}

const apptTimes = {
  'hours': {
    'monday': [
      {'open': 0, 'close': 19800},
      {'open': 27000, 'close': 39600},
      {'open': 43200, 'close': 61200},
      {'open': 66600, 'close': 72000}
    ],
    'tuesday': [
      {'open': 27000, 'close': 39600}
    ],
    'wednesday': [
      {'open': 27000, 'close': 39600}
    ],
    'thursday': [],
    'friday': [
      {'open': 50400, 'close': 63000}
    ],
    'saturday': [],
    'sunday': []
  },
  'hoursType': 'WEEKLY'
};
