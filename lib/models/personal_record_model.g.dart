// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalRecordModel _$PersonalRecordModelFromJson(Map<String, dynamic> json) =>
    PersonalRecordModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      date: PersonalRecordModel._timestampFromJson(json['date']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PersonalRecordModelToJson(
  PersonalRecordModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'clientId': instance.clientId,
  'exerciseName': instance.exerciseName,
  'weight': instance.weight,
  'reps': instance.reps,
  'date': PersonalRecordModel._timestampToJson(instance.date),
  'notes': instance.notes,
};
