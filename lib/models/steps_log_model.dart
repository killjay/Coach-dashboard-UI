import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'steps_log_model.g.dart';

@JsonSerializable()
class StepsLogModel {
  final String id;
  final String clientId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final int steps;
  final int goal;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime loggedAt;

  StepsLogModel({
    required this.id,
    required this.clientId,
    required this.date,
    required this.steps,
    required this.goal,
    required this.loggedAt,
  });

  factory StepsLogModel.fromJson(Map<String, dynamic> json) => _$StepsLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$StepsLogModelToJson(this);

  double get progress => steps / goal;

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

