import 'package:json_annotation/json_annotation.dart';

part 'demographics_model.g.dart';

enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}

@JsonSerializable()
class DemographicsModel {
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? dateOfBirth;
  final Gender? gender;
  final double? heightCm; // Height in centimeters
  final double? weightKg; // Weight in kilograms

  DemographicsModel({
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
  });

  factory DemographicsModel.fromJson(Map<String, dynamic> json) => _$DemographicsModelFromJson(json);
  Map<String, dynamic> toJson() => _$DemographicsModelToJson(this);

  // Helper methods for unit conversion
  double? get heightInFeet {
    if (heightCm == null) return null;
    return heightCm! / 30.48; // Convert cm to feet
  }

  double? get weightInLbs {
    if (weightKg == null) return null;
    return weightKg! * 2.20462; // Convert kg to lbs
  }

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.parse(value);
    }
    return null;
  }

  static String? _dateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}




