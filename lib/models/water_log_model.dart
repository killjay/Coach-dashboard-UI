import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'water_log_model.g.dart';

@JsonSerializable()
class WaterLogModel {
  final String id;
  final String clientId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final double amount; // in ml
  final double goal; // in ml
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime loggedAt;

  WaterLogModel({
    required this.id,
    required this.clientId,
    required this.date,
    required this.amount,
    required this.goal,
    required this.loggedAt,
  });

  factory WaterLogModel.fromJson(Map<String, dynamic> json) => _$WaterLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$WaterLogModelToJson(this);

  double get progress => amount / goal;

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




