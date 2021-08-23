import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/utils/seconds_to_time.dart';

class BookingSummary extends StatelessWidget {
  const BookingSummary({
    Key? key,
    required this.bookedService,
    required this.date,
    required this.timeInSecs,
  }) : super(key: key);

  final DbNearbyService bookedService;
  final DateTime date;
  final int timeInSecs;

  @override
  Widget build(BuildContext context) {
    final friendlyDayTimeBuilder = StringBuffer();
    friendlyDayTimeBuilder.writeAll([
      DateFormat.yMMMMEEEEd().format(date).substring(0, 3),
      secondsToTime(timeInSecs),
    ], ' ');
    return Row(
      children: [
        Column(
          children: [
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              DateFormat.yMMMMd().format(date).substring(0, 3),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...[
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.subtitle2,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.home_repair_service_outlined),
                        ),
                      ),
                      TextSpan(text: bookedService.serviceName),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
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
              ].expand((widget) => [widget, const SizedBox(height: 8)]),
            ],
          ),
        ),
      ],
    );
  }
}
