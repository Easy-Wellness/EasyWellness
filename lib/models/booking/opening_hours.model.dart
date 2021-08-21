import 'package:json_annotation/json_annotation.dart';

part 'opening_hours.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class OpeningHours {
  OpeningHours({
    required this.hours,
    required this.hoursType,
  });

  final Hours hours;

  /// Possible values: "NO_HOURS_AVAILABLE", "ALWAYS_OPEN", and "WEEKLY"
  final String hoursType;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);

  Map<String, dynamic> toJson() => _$OpeningHoursToJson(this);
}

/// In each weekday (e.g. mon, tue, wed, etc.), different open-close periods
/// represent different parts of the day (early morning, morning,
/// afternoon, and evening)
@JsonSerializable(anyMap: true, explicitToJson: true)
class Hours {
  Hours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  final List<OpenCloseTimesInSecs> monday;
  final List<OpenCloseTimesInSecs> tuesday;
  final List<OpenCloseTimesInSecs> wednesday;
  final List<OpenCloseTimesInSecs> thursday;
  final List<OpenCloseTimesInSecs> friday;
  final List<OpenCloseTimesInSecs> saturday;
  final List<OpenCloseTimesInSecs> sunday;

  factory Hours.fromJson(Map<String, dynamic> json) => _$HoursFromJson(json);

  Map<String, dynamic> toJson() => _$HoursToJson(this);
}

/// Both [open] and [close] are the number of seconds from midnight 12:00 AM
@JsonSerializable(anyMap: true, explicitToJson: true)
class OpenCloseTimesInSecs {
  OpenCloseTimesInSecs({
    required this.open,
    required this.close,
  });

  final int open;
  final int close;

  factory OpenCloseTimesInSecs.fromJson(Map<String, dynamic> json) =>
      _$OpenCloseTimesInSecsFromJson(json);

  Map<String, dynamic> toJson() => _$OpenCloseTimesInSecsToJson(this);
}
