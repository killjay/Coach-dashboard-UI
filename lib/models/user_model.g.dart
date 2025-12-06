// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  createdAt: UserModel._timestampFromJson(json['createdAt']),
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$UserRoleEnumMap[instance.role]!,
  'createdAt': UserModel._timestampToJson(instance.createdAt),
  'profileImageUrl': instance.profileImageUrl,
};

const _$UserRoleEnumMap = {UserRole.coach: 'coach', UserRole.client: 'client'};
