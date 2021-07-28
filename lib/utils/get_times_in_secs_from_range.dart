/// In the returned list of times, the difference between two adjacent times
/// is always [intervalInSecs]. Only use this util when u work with time in
/// seconds (unit of measurement) from midnight 12:00 AM.
///
/// By default, each time interval is equal to 30 minutes. The
/// returned list of points are arranged in ascending order from
/// [startTimeInSecs] to [endTimeInSecs]
List<int> getTimesInSecsFromRange(int startTimeInSecs, int endTimeInSecs,
    [int intervalInSecs = 1800]) {
  final List<int> points = [];
  int endPoint = startTimeInSecs;
  while (endPoint <= endTimeInSecs) {
    points.add(endPoint);
    endPoint += intervalInSecs;
  }
  return points;
}
