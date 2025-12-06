// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressPhotoModel _$ProgressPhotoModelFromJson(Map<String, dynamic> json) =>
    ProgressPhotoModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      date: ProgressPhotoModel._timestampFromJson(json['date']),
      imageUrl: json['imageUrl'] as String,
      weekNumber: (json['weekNumber'] as num).toInt(),
      uploadedAt: ProgressPhotoModel._timestampFromJson(json['uploadedAt']),
    );

Map<String, dynamic> _$ProgressPhotoModelToJson(ProgressPhotoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'date': ProgressPhotoModel._timestampToJson(instance.date),
      'imageUrl': instance.imageUrl,
      'weekNumber': instance.weekNumber,
      'uploadedAt': ProgressPhotoModel._timestampToJson(instance.uploadedAt),
    };
