class LatitudeLongitudeModel {
  final double latitude;
  final double longitude;

  LatitudeLongitudeModel({
    required this.latitude,
    required this.longitude,
  });

  factory LatitudeLongitudeModel.fromData({
    required double latitude,
    required double longitude,
  }) {
    return LatitudeLongitudeModel(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
