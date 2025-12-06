import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'assigned_diet_model.g.dart';

@JsonSerializable()
class AssignedDietModel {
  final String id;
  final String planId;
  final String clientId;
  final String coachId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime startDate;
  @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
  final DateTime? endDate;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime assignedAt;

  AssignedDietModel({
    required this.id,
    required this.planId,
    required this.clientId,
    required this.coachId,
    required this.startDate,
    this.endDate,
    required this.assignedAt,
  });

  factory AssignedDietModel.fromJson(Map<String, dynamic> json) => _$AssignedDietModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedDietModelToJson(this);

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

  static DateTime? _timestampFromJsonNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  static dynamic _timestampToJsonNullable(DateTime? dateTime) {
    return dateTime != null ? Timestamp.fromDate(dateTime) : null;
  }
}

