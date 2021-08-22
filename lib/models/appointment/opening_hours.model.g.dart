// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_hours.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpeningHours _$OpeningHoursFromJson(Map json) {
  return OpeningHours(
    hours: Hours.fromJson(Map<String, dynamic>.from(json['hours'] as Map)),
    hoursType: json['hoursType'] as String,
  );
}

Map<String, dynamic> _$OpeningHoursToJson(OpeningHours instance) =>
    <String, dynamic>{
      'hours': instance.hours,
      'hoursType': instance.hoursType,
    };

Hours _$HoursFromJson(Map json) {
  return Hours(
    monday: (json['monday'] as List<dynamic>)
        .map((e) =>
            OpenCloseTimesInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    tuesday: (json['tuesday'] as List<dynamic>)
        .map((e) =>
            OpenCloseTimesInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    wednesday: (json['wednesday'] as List<dynamic>)
        .map((e) =>
            OpenCloseTimesInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    thursday: (json['thursday'] as List<dynamic>)
        .map((e) =>
            OpenCloseTimesInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    friday: (json['friday'] as List<dynamic>)
        .map((e) =>
            OpenCloseTimesInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    saturday: (json['saturday'] as List<dynamic>)
        .map((e) =>
            OpenCloseTimesInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    sunday: (json['sunday'] as List<dynamic>)
        .map((e) =>
            OpenCloseTimesInSecs.fromJson(Map<String, dynamic>.from(e as Map)))
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

OpenCloseTimesInSecs _$OpenCloseTimesInSecsFromJson(Map json) {
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
