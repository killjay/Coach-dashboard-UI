import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'personal_record_model.g.dart';

@JsonSerializable()
class PersonalRecordModel {
  final String id;
  final String clientId;
  final String exerciseName;
  final double weight; // in kg or lbs
  final int reps;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final String? notes;

  PersonalRecordModel({
    required this.id,
    required this.clientId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.date,
    this.notes,
  });

  factory PersonalRecordModel.fromJson(Map<String, dynamic> json) => _$PersonalRecordModelFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalRecordModelToJson(this);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}




