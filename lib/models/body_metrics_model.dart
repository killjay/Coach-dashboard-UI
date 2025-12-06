import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'body_metrics_model.g.dart';

@JsonSerializable()
class BodyMetricsModel {
  final String id;
  final String clientId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final double? weight; // in kg
  final double? bodyFat; // percentage
  final double? waist; // in cm
  final double? chest; // in cm
  final double? hips; // in cm
  final double? bmi; // calculated from weight and height
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime loggedAt;

  BodyMetricsModel({
    required this.id,
    required this.clientId,
    required this.date,
    this.weight,
    this.bodyFat,
    this.waist,
    this.chest,
    this.hips,
    this.bmi,
    required this.loggedAt,
  });

  factory BodyMetricsModel.fromJson(Map<String, dynamic> json) => _$BodyMetricsModelFromJson(json);
  Map<String, dynamic> toJson() => _$BodyMetricsModelToJson(this);

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




