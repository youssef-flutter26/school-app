class TripLocationModel {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final String? driverName;
  final String? tripStatus;

  TripLocationModel({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.driverName,
    this.tripStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading ?? 0.0,
      'speed': speed ?? 0.0,
    };
  }

  factory TripLocationModel.fromJson(Map<String, dynamic> json) {
    return TripLocationModel(
      latitude: (json['latitude'] ?? json['lat'] as num).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] as num).toDouble(),
      heading:
          json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      driverName: json['driver_name'] ?? json['driverName'],
      tripStatus: json['status'],
    );
  }
}
