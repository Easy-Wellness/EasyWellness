import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/utils/seconds_to_time.dart';

class CreateBookingScreen extends StatelessWidget {
  static const String routeName = '/create_booking';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomOffset = mq.viewInsets.bottom + mq.padding.bottom;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Your booking summary',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        body: AnimatedContainer(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 350),
          padding: EdgeInsets.only(bottom: bottomOffset),
          child: SafeArea(
            bottom: false,
            child: Body(),
          ),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final bookedService = args['bookedService'] as DbNearbyService;
    final selectedDateTime = args['selecteDateTime'] as DateTime;
    final timeInSecs = args['timeInSecs'] as int;
    return Container(
      child: Column(
        children: [
          BookingSummary(
            selectedDateTime: selectedDateTime,
            bookedService: bookedService,
            timeInSecs: timeInSecs,
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: Divider(thickness: 2),
          ),
          BookingForm(),
        ],
      ),
    );
  }
}

class BookingSummary extends StatelessWidget {
  const BookingSummary({
    Key? key,
    required this.selectedDateTime,
    required this.bookedService,
    required this.timeInSecs,
  }) : super(key: key);

  final DbNearbyService bookedService;
  final DateTime selectedDateTime;
  final int timeInSecs;

  @override
  Widget build(BuildContext context) {
    final friendlyDayTimeBuilder = StringBuffer();
    friendlyDayTimeBuilder.writeAll([
      DateFormat.yMMMMEEEEd().format(selectedDateTime).substring(0, 3),
      secondsToTime(timeInSecs),
    ], ' ');
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '${selectedDateTime.day}',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.yMMMMd().format(selectedDateTime).substring(0, 3),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.subtitle2,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.summarize_outlined),
                        ),
                      ),
                      TextSpan(text: bookedService.serviceName),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.place),
                        ),
                      ),
                      TextSpan(text: bookedService.placeName),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.map_outlined),
                        ),
                      ),
                      TextSpan(text: bookedService.address),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.schedule),
                        ),
                      ),
                      TextSpan(text: friendlyDayTimeBuilder.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingForm extends StatelessWidget {
  const BookingForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Reason for visit',
                  alignLabelWithHint: true,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: 'Please describe your symptoms',
                ),
                minLines: 3,
                maxLines: 6,
                maxLength: 300,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Reserve'),
            ),
          ),
        ],
      ),
    );
  }
}
