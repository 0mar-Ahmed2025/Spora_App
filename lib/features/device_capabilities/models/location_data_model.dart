class LocationDataModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime retrievalTime;

  const LocationDataModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.retrievalTime,
  });
}
