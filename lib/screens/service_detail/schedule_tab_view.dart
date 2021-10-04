import 'package:flutter/material.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/models/place/db_place.model.dart';
import 'package:users/utils/time_slot_is_booked.dart';
import 'package:users/widgets/appointment_scheduler.dart';

import 'create_booking_screen.dart';


class ScheduleTabView extends StatelessWidget {
  const ScheduleTabView({
    Key? key,
    required this.placeData,
    required this.serviceId,
    required this.serviceData,
  }) : super(key: key);

  final DbPlace placeData;
  final String serviceId;
  final DbNearbyService serviceData;

  @override
  Widget build(BuildContext context) {
    final policyStringBuilder = StringBuffer();
    policyStringBuilder
      ..write(
          'If you need to cancel or reschedule your appointment, be sure to ')
      ..write('do it more than ${serviceData.minLeadHours} hour(s) in advance.')
      ..write(' We will NOT allow you to cancel or reschedule less than ')
      ..write(
          '${serviceData.minLeadHours} hour(s) prior to your scheduled time slot.');

    return Scrollbar(
      isAlwaysShown: true,
      interactive: true,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.home_repair_service_outlined),
                        ),
                      ),
                      TextSpan(text: serviceData.serviceName),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.policy_outlined),
                        ),
                      ),
                      TextSpan(text: policyStringBuilder.toString()),
                    ],
                  ),
                ),
                const Divider(thickness: 1, height: 32),
                AppointmentScheduler(
                  validator: (value) async {
                    if (await timeSlotIsBooked(value))
                      return 'You already have an appointment at this time';
                  },
                  onTimeSlotSelect: (selectedDateTime) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateBookingScreen(
                        serviceId: serviceId,
                        bookedService: serviceData,
                        selectedDateTime: selectedDateTime,
                      ),
                    ),
                  ),
                  minuteIncrements: serviceData.minuteIncrements!,
                  minLeadHours: serviceData.minLeadHours!,
                  maxLeadDays: serviceData.maxLeadDays!,
                  weeklySchedule: placeData.workingHours,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
