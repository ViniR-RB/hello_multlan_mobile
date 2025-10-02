import 'package:json_annotation/json_annotation.dart';

part 'occurence_model.g.dart';

enum OccurrenceStatus {
  @JsonValue('CREATED')
  // ignore: constant_identifier_names
  CREATED('CREATED'),
  @JsonValue('RESOLVED')
  // ignore: constant_identifier_names
  RESOLVED('RESOLVED'),
  @JsonValue('CANCELED')
  // ignore: constant_identifier_names
  CANCELED('CANCELED');

  const OccurrenceStatus(this.value);
  final String value;
}

@JsonSerializable()
class OccurrenceModel {
  final String id;
  final String title;
  final String description;
  final OccurrenceStatus status;
  final String? canceledReason;
  final String? boxId;
  final DateTime createdAt;
  final DateTime updatedAt;

  OccurrenceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.canceledReason,
    this.boxId,
    required this.createdAt,
    required this.updatedAt,
  });
  factory OccurrenceModel.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$OccurrenceModelToJson(this);
}
