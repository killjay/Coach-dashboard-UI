// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetLogModel _$SetLogModelFromJson(Map<String, dynamic> json) => SetLogModel(
  setNumber: (json['setNumber'] as num).toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  reps: (json['reps'] as num?)?.toInt(),
  rpe: json['rpe'] as String?,
  notes: json['notes'] as String?,
  completed: json['completed'] as bool? ?? false,
);

Map<String, dynamic> _$SetLogModelToJson(SetLogModel instance) =>
    <String, dynamic>{
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'notes': instance.notes,
      'completed': instance.completed,
    };
