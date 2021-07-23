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
    name: json['name'] as String,
    geoPosition:
        GeoPosition.fromJson(json['geoPosition'] as Map<String, dynamic>),
    address: json['address'] as String,
  );
}

Map<String, dynamic> _$DbNearbyServiceToJson(DbNearbyService instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'ratingsTotal': instance.ratingsTotal,
      'specialty': instance.specialty,
      'name': instance.name,
      'address': instance.address,
      'geoPosition': instance.geoPosition,
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
