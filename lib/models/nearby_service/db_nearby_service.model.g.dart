// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_nearby_service.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbNearbyService _$DbNearbyServiceFromJson(Map<String, dynamic> json) {
  return DbNearbyService(
    rating: (json['rating'] as num).toDouble(),
    ratingsTotal: json['ratingsTotal'] as int,
    specialty: json['specialty'] as String,
    serviceName: json['serviceName'] as String? ?? '',
    placeName: json['placeName'] as String? ?? '',
    placeId: json['placeId'] as String? ?? '',
    address: json['address'] as String,
    geoPosition:
        GeoPosition.fromJson(json['geoPosition'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DbNearbyServiceToJson(DbNearbyService instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'ratingsTotal': instance.ratingsTotal,
      'specialty': instance.specialty,
      'address': instance.address,
      'geoPosition': instance.geoPosition,
      'serviceName': instance.serviceName,
      'placeName': instance.placeName,
      'placeId': instance.placeId,
    };

GeoPosition _$GeoPositionFromJson(Map<String, dynamic> json) {
  return GeoPosition(
    geohash: json['geohash'] as String,
    geopoint: GeoPosition._fromJsonGeoPoint(json['geopoint'] as GeoPoint),
  );
}

Map<String, dynamic> _$GeoPositionToJson(GeoPosition instance) =>
    <String, dynamic>{
      'geohash': instance.geohash,
      'geopoint': GeoPosition._toJsonGeoPoint(instance.geopoint),
    };
