// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_review.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbReview _$DbReviewFromJson(Map json) {
  return DbReview(
    accountId: json['account_id'] as String,
    placeId: json['place_id'] as String,
    serviceId: json['service_id'] as String,
    rating: (json['rating'] as num).toDouble(),
    review: json['review'] as String?,
    createdAt: DbReview._fromJsonTimestamp(json['created_at'] as Timestamp),
  );
}

Map<String, dynamic> _$DbReviewToJson(DbReview instance) => <String, dynamic>{
      'account_id': instance.accountId,
      'place_id': instance.placeId,
      'service_id': instance.serviceId,
      'rating': instance.rating,
      'review': instance.review,
      'created_at': DbReview._toJsonTimestamp(instance.createdAt),
    };
