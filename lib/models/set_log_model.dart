import 'package:json_annotation/json_annotation.dart';

part 'set_log_model.g.dart';

@JsonSerializable()
class SetLogModel {
  final int setNumber;
  final double? weight; // Actual weight used
  final int? reps; // Actual reps completed
  final String? rpe; // Rate of Perceived Exertion
  final String? notes;
  final bool completed;

  SetLogModel({
    required this.setNumber,
    this.weight,
    this.reps,
    this.rpe,
    this.notes,
    this.completed = false,
  });

  factory SetLogModel.fromJson(Map<String, dynamic> json) => _$SetLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$SetLogModelToJson(this);
}




