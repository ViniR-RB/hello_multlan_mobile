import 'package:json_annotation/json_annotation.dart';

part 'occurence_model.g.dart';

@JsonSerializable()
class OccurrenceModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String boxId;
  final String createdByUserId;
  final String receivedByUserId;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  OccurrenceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.boxId,
    required this.createdByUserId,
    required this.receivedByUserId,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OccurrenceModel.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$OccurrenceModelToJson(this);
}
