import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'invitation_model.g.dart';

@JsonSerializable()
class InvitationModel {
  final String id;
  final String coachId;
  final String code; // Unique invitation code
  final String? email; // Optional: if sent via email
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime expiresAt;
  final bool used;
  final String? usedBy; // clientId who used it
  @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
  final DateTime? usedAt;

  InvitationModel({
    required this.id,
    required this.coachId,
    required this.code,
    this.email,
    required this.createdAt,
    required this.expiresAt,
    this.used = false,
    this.usedBy,
    this.usedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) => _$InvitationModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvitationModelToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !used && !isExpired;

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

