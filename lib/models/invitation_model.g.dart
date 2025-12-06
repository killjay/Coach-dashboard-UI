// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationModel _$InvitationModelFromJson(Map<String, dynamic> json) =>
    InvitationModel(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      code: json['code'] as String,
      email: json['email'] as String?,
      createdAt: InvitationModel._timestampFromJson(json['createdAt']),
      expiresAt: InvitationModel._timestampFromJson(json['expiresAt']),
      used: json['used'] as bool? ?? false,
      usedBy: json['usedBy'] as String?,
      usedAt: InvitationModel._timestampFromJsonNullable(json['usedAt']),
    );

Map<String, dynamic> _$InvitationModelToJson(InvitationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coachId': instance.coachId,
      'code': instance.code,
      'email': instance.email,
      'createdAt': InvitationModel._timestampToJson(instance.createdAt),
      'expiresAt': InvitationModel._timestampToJson(instance.expiresAt),
      'used': instance.used,
      'usedBy': instance.usedBy,
      'usedAt': InvitationModel._timestampToJsonNullable(instance.usedAt),
    };
