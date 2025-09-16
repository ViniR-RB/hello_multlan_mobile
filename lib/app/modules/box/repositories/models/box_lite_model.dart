import 'package:json_annotation/json_annotation.dart';

part 'box_lite_model.g.dart';

@JsonSerializable()
class BoxLiteModel {
  final String id;
  final String label;
  final double latitude;
  final double longitude;

  BoxLiteModel({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
  });
  factory BoxLiteModel.fromJson(Map<String, dynamic> json) =>
      _$BoxLiteModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoxLiteModelToJson(this);
}
