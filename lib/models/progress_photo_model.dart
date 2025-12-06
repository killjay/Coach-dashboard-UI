import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'progress_photo_model.g.dart';

@JsonSerializable()
class ProgressPhotoModel {
  final String id;
  final String clientId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final String imageUrl;
  final int weekNumber;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime uploadedAt;

  ProgressPhotoModel({
    required this.id,
    required this.clientId,
    required this.date,
    required this.imageUrl,
    required this.weekNumber,
    required this.uploadedAt,
  });

  factory ProgressPhotoModel.fromJson(Map<String, dynamic> json) => _$ProgressPhotoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressPhotoModelToJson(this);

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




