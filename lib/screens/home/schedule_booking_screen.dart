import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';

class BookingScreen extends StatelessWidget {
  static const String routeName = '/create_booking';

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
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate,
      lastDate: selectedDate.add(const Duration(days: 120)),
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
          TimeSlotSelector(),
        ],
      ),
    );
  }
}

class TimeSlotSelector extends StatefulWidget {
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
      children: [
        ExpansionPanelRadio(
          value: 'morning',
          canTapOnHeader: true,
          headerBuilder: (context, isOpen) => ListTile(
            title: Text(
              'Morning (from 6AM to 11:45 AM)',
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
              for (String key in timeSlots.keys)
                OutlinedButton(
                  onPressed: timeSlots[key] == 0 ? null : () {},
                  child: Text('$key AM'),
                )
            ],
          ),
        ),
        ExpansionPanelRadio(
          value: 'evening',
          canTapOnHeader: true,
          headerBuilder: (context, isOpen) => ListTile(
            title: Text(
              'Evening (from 6PM to 11:45 PM)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          body: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            padding: const EdgeInsets.all(8),
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              for (String key in timeSlots.keys)
                OutlinedButton(
                  onPressed: timeSlots[key] == 0 ? null : () {},
                  child: Text('$key PM'),
                )
            ],
          ),
        ),
      ],
    );
  }
}

const Map<String, int> timeSlots = {
  '06:00': 3,
  '06:30': 0,
  '07:00': 3,
  '07:30': 0,
  '08:00': 3,
  '08:30': 0,
  '09:00': 3,
  '09:30': 3,
  '10:00': 0,
  '10:30': 3,
  '11:00': 0,
  '11:30': 3,
};
