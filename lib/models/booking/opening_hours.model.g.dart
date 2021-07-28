// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_hours.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpeningHours _$OpeningHoursFromJson(Map<String, dynamic> json) {
  return OpeningHours(
    hours: Hours.fromJson(json['hours'] as Map<String, dynamic>),
    hoursType: json['hoursType'] as String,
  );
}

Map<String, dynamic> _$OpeningHoursToJson(OpeningHours instance) =>
    <String, dynamic>{
      'hours': instance.hours,
      'hoursType': instance.hoursType,
    };

Hours _$HoursFromJson(Map<String, dynamic> json) {
  return Hours(
    monday: (json['monday'] as List<dynamic>)
        .map((e) => OpenCloseTimesInSecs.fromJson(e as Map<String, dynamic>))
        .toList(),
    tuesday: (json['tuesday'] as List<dynamic>)
        .map((e) => OpenCloseTimesInSecs.fromJson(e as Map<String, dynamic>))
        .toList(),
    wednesday: (json['wednesday'] as List<dynamic>)
        .map((e) => OpenCloseTimesInSecs.fromJson(e as Map<String, dynamic>))
        .toList(),
    thursday: (json['thursday'] as List<dynamic>)
        .map((e) => OpenCloseTimesInSecs.fromJson(e as Map<String, dynamic>))
        .toList(),
    friday: (json['friday'] as List<dynamic>)
        .map((e) => OpenCloseTimesInSecs.fromJson(e as Map<String, dynamic>))
        .toList(),
    saturday: (json['saturday'] as List<dynamic>)
        .map((e) => OpenCloseTimesInSecs.fromJson(e as Map<String, dynamic>))
        .toList(),
    sunday: (json['sunday'] as List<dynamic>)
        .map((e) => OpenCloseTimesInSecs.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$HoursToJson(Hours instance) => <String, dynamic>{
      'monday': instance.monday,
      'tuesday': instance.tuesday,
      'wednesday': instance.wednesday,
      'thursday': instance.thursday,
      'friday': instance.friday,
      'saturday': instance.saturday,
      'sunday': instance.sunday,
    };

OpenCloseTimesInSecs _$OpenCloseTimesInSecsFromJson(Map<String, dynamic> json) {
  return OpenCloseTimesInSecs(
    open: json['open'] as int,
    close: json['close'] as int,
  );
}

Map<String, dynamic> _$OpenCloseTimesInSecsToJson(
        OpenCloseTimesInSecs instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
    };
