String formatDuration(int minutes) {
  final duration = Duration(minutes: minutes);
  final nHours = duration.inHours;
  final hoursText = nHours >= 1 ? '${nHours}h ' : '';
  final remainingMins = duration.inMinutes.remainder(60);
  final minutesText = remainingMins == 0 ? '' : '$remainingMins mins';
  return hoursText + minutesText;
}
