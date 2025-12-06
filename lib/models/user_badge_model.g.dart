// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBadgeModel _$UserBadgeModelFromJson(Map<String, dynamic> json) =>
    UserBadgeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      badgeId: json['badgeId'] as String,
      earnedDate: UserBadgeModel._timestampFromJson(json['earnedDate']),
    );

Map<String, dynamic> _$UserBadgeModelToJson(UserBadgeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'badgeId': instance.badgeId,
      'earnedDate': UserBadgeModel._timestampToJson(instance.earnedDate),
    };
