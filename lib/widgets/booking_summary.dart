import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/utils/seconds_to_friendly_time.dart';

class BookingSummary extends StatelessWidget {
  const BookingSummary({
    Key? key,
    required this.serviceName,
    required this.placeName,
    required this.address,
    required this.dateTime,
  }) : super(key: key);

  final String serviceName;
  final String placeName;
  final String address;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat.yMMMMd().format(dateTime).substring(0, 3);
    final timeInSecs = (dateTime.millisecondsSinceEpoch -
            DateUtils.dateOnly(dateTime).millisecondsSinceEpoch) ~/
        1000;
    final friendlyDayTimeBuilder = StringBuffer();
    friendlyDayTimeBuilder.writeAll([
      DateFormat.yMMMMEEEEd().format(dateTime).substring(0, 3),
      secondsToFriendlyTime(timeInSecs),
    ], ' ');
    return Row(
      children: [
        Column(
          children: [
            Text(
              '${dateTime.day}',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(month, style: Theme.of(context).textTheme.subtitle1),
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
                      TextSpan(text: serviceName),
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
                      TextSpan(text: placeName),
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
                      TextSpan(text: address),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
