import 'package:json_annotation/json_annotation.dart';

part 'box_model.g.dart';

@JsonSerializable()
class BoxModel {
  final String id;
  final String label;
  final num latitude;
  final num longitude;
  final int freeSpace;
  final int filledSpace;
  final num signal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> listUser;
  final String? note;
  final String imageUrl;
  final String zone;
  final String? routeId;

  BoxModel({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.freeSpace,
    required this.filledSpace,
    required this.signal,
    required this.createdAt,
    required this.updatedAt,
    required this.listUser,
    required this.note,
    required this.imageUrl,
    required this.zone,
    this.routeId,
  });

  factory BoxModel.fromJson(Map<String, dynamic> json) =>
      _$BoxModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoxModelToJson(this);
}
