import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'sleep_log_model.g.dart';

@JsonSerializable()
class SleepLogModel {
  final String id;
  final String clientId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final int timeInBedMinutes; // Total time in bed in minutes
  final int timeAsleepMinutes; // Actual sleep time in minutes
  final double efficiency; // Calculated: timeAsleep / timeInBed
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime loggedAt;

  SleepLogModel({
    required this.id,
    required this.clientId,
    required this.date,
    required this.timeInBedMinutes,
    required this.timeAsleepMinutes,
    required this.efficiency,
    required this.loggedAt,
  });

  factory SleepLogModel.fromJson(Map<String, dynamic> json) => _$SleepLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$SleepLogModelToJson(this);

  String get timeInBedFormatted {
    final hours = timeInBedMinutes ~/ 60;
    final minutes = timeInBedMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get timeAsleepFormatted {
    final hours = timeAsleepMinutes ~/ 60;
    final minutes = timeAsleepMinutes % 60;
    return '${hours}h ${minutes}m';
  }

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




