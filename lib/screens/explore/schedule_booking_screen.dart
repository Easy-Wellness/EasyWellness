import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/booking/opening_hours.model.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/utils/get_times_in_secs_from_range.dart';
import 'package:users/utils/seconds_to_time.dart';

import 'create_booking_screen.dart';

class ScheduleBookingScreen extends StatelessWidget {
  static const String routeName = '/schedule_booking';

  @override
  Widget build(BuildContext context) {
    final service = (ModalRoute.of(context)!.settings.arguments
        as Map<String, Object>)['service'] as DbNearbyService;
    return DefaultTabController(
      initialIndex: 0,
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
              Tab(text: 'information'.toUpperCase()),
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

  void setSelectedDate(DateTime? date) {
    if (date != null && date != selectedDate)
      setState(() => selectedDate = date);
  }

  Future<void> _selectDate(BuildContext context) async {
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
    return Container(
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

          /// Must drop a unique key here or
          /// an unknown weird error will be thown (I don't know why)
          DayPartPanelList(
            key: UniqueKey(),
            selectedDate: selectedDate,
            onAnotherDateSelect: setSelectedDate,
          ),
        ],
      ),
    );
  }
}

class DayPartPanelList extends StatelessWidget {
  const DayPartPanelList({
    Key? key,
    required this.selectedDate,
    required this.onAnotherDateSelect,
  }) : super(key: key);

  final DateTime selectedDate;
  final void Function(DateTime? date) onAnotherDateSelect;

  @override
  Widget build(BuildContext context) {
    /// There are at most 4 different objects in the list below, each one is
    /// mapped to a different part of the day
    final openingHoursForSelectedDate = OpeningHours.fromJson(apptTimesInSecs)
            .hours
            .toJson()[DateFormat('EEEE').format(selectedDate).toLowerCase()]
        as List<OpenCloseTimesInSecs>;
    final dayPartPanels =
        buildDayPartPanels(context, selectedDate, openingHoursForSelectedDate);
    return dayPartPanels.length == 0
        ? Expanded(
            child: Column(
              children: [
                Text(
                  'Oops, there are no hours available for this day',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(height: 8),
                Text(
                  'Please select another day',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => onAnotherDateSelect(
                      selectedDate.add(const Duration(days: 1))),
                  child: Text('Select another day'),
                ),
              ],
            ),
          )
        : ExpansionPanelList.radio(
            animationDuration: const Duration(milliseconds: 800),
            children: dayPartPanels,
          );
  }
}

List<ExpansionPanelRadio> buildDayPartPanels(
  BuildContext context,
  DateTime selectedDate,
  List<OpenCloseTimesInSecs> openingHoursInSecs,
) {
  final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
  final serviceId = args['serviceId'] as String;
  final service = args['service'] as DbNearbyService;
  final List<ExpansionPanelRadio> panelRadios = [];

  openingHoursInSecs.forEach((rangeInSecs) {
    final currentDateTime = DateTime.now();
    final timesInSecs =
        getTimesInSecsFromRange(rangeInSecs.open, rangeInSecs.close);
    if (selectedDate
        .add(Duration(seconds: timesInSecs[timesInSecs.length - 1]))
        .isBefore(currentDateTime.add(const Duration(minutes: 40)))) return;
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
            if (currentDateTime.add(const Duration(minutes: 40)).compareTo(
                    selectedDate.add(Duration(seconds: timeInSecs))) <=
                0)
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(
                    context, CreateBookingScreen.routeName,
                    arguments: {
                      'serviceId': serviceId,
                      'bookedService': service,
                      'selecteDateTime':
                          selectedDate.add(Duration(seconds: timeInSecs)),
                      'timeInSecs': timeInSecs,
                    }),
                child: Text(secondsToTime(timeInSecs)),
              )
        ],
      ),
    ));
  });
  return panelRadios;
}

const apptTimesInSecs = {
  'hours': {
    'monday': [
      {'open': 0, 'close': 20700},
      {'open': 21600, 'close': 42300},
      {'open': 43200, 'close': 63900},
      {'open': 64800, 'close': 85500}
    ],
    'tuesday': [],
    'wednesday': [],
    'thursday': [],
    'friday': [
      {'open': 50400, 'close': 63000}
    ],
    'saturday': [
      {'open': 0, 'close': 19800},
      {'open': 27000, 'close': 39600},
      {'open': 43200, 'close': 61200},
      {'open': 64800, 'close': 85500}
    ],
    'sunday': []
  },
  'hoursType': 'WEEKLY'
};
