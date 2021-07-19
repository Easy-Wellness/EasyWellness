// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmp_nearby_place.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleMapsNearbyPlace _$GoogleMapsNearbyPlaceFromJson(
    Map<String, dynamic> json) {
  return GoogleMapsNearbyPlace(
    businessStatus: json['business_status'] as String,
    geometry:
        GoogleMapsGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
    name: json['name'] as String,
    placeId: json['place_id'] as String,
    plusCode: PlusCode.fromJson(json['plus_code'] as Map<String, dynamic>),
    rating: json['rating'] as int,
    userRatingsTotal: json['user_ratings_total'] as int,
    vicinity: json['vicinity'] as String,
  );
}

Map<String, dynamic> _$GoogleMapsNearbyPlaceToJson(
        GoogleMapsNearbyPlace instance) =>
    <String, dynamic>{
      'name': instance.name,
      'rating': instance.rating,
      'vicinity': instance.vicinity,
      'geometry': instance.geometry,
      'place_id': instance.placeId,
      'business_status': instance.businessStatus,
      'user_ratings_total': instance.userRatingsTotal,
      'plus_code': instance.plusCode,
    };

PlusCode _$PlusCodeFromJson(Map<String, dynamic> json) {
  return PlusCode(
    compoundCode: json['compound_code'] as String,
    globalCode: json['global_code'] as String,
  );
}

Map<String, dynamic> _$PlusCodeToJson(PlusCode instance) => <String, dynamic>{
      'compound_code': instance.compoundCode,
      'global_code': instance.globalCode,
    };
