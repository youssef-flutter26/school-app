class DriverDashboardModel {
  final String role;
  final DriverMetrics metrics;

  DriverDashboardModel({required this.role, required this.metrics});

  factory DriverDashboardModel.fromJson(Map<String, dynamic> json) {
    return DriverDashboardModel(
      role: json['role'] ?? '',
      metrics: DriverMetrics.fromJson(json['metrics'] ?? {}),
    );
  }
}

class DriverMetrics {
  final int students;
  final int vehicles;
  final int trips;
  final int activeTrips;
  final int openIncidents;

  DriverMetrics({
    required this.students,
    required this.vehicles,
    required this.trips,
    required this.activeTrips,
    required this.openIncidents,
  });

  factory DriverMetrics.fromJson(Map<String, dynamic> json) {
    return DriverMetrics(
      students: json['students'] ?? 0,
      vehicles: json['vehicles'] ?? 0,
      trips: json['trips'] ?? 0,
      activeTrips: json['activeTrips'] ?? 0,
      openIncidents: json['openIncidents'] ?? 0,
    );
  }
}

class DriverTripModel {
  final int id;
  final int routeId;
  final int vehicleId;
  final int driverUserId;
  final int attendantUserId;
  final String tripType;
  final String scheduledAt;
  final String status;

  DriverTripModel({
    required this.id,
    required this.routeId,
    required this.vehicleId,
    required this.driverUserId,
    required this.attendantUserId,
    required this.tripType,
    required this.scheduledAt,
    required this.status,
  });

  factory DriverTripModel.fromJson(Map<String, dynamic> json) {
    return DriverTripModel(
      id: json['id'] ?? 0,
      routeId: json['route_id'] ?? 0,
      vehicleId: json['vehicle_id'] ?? 0,
      driverUserId: json['driver_user_id'] ?? 0,
      attendantUserId: json['attendant_user_id'] ?? 0,
      tripType: json['trip_type'] ?? '',
      scheduledAt: json['scheduled_at'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class DriverStudentModel {
  final int id;
  final String studentCode;
  final String fullName;
  final String grade;
  final String pickupStop;
  final String status;

  DriverStudentModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.grade,
    required this.pickupStop,
    required this.status,
  });

  factory DriverStudentModel.fromJson(Map<String, dynamic> json) {
    return DriverStudentModel(
      id: json['id'] ?? 0,
      studentCode: json['student_code'] ?? '',
      fullName: json['full_name'] ?? '',
      grade: json['grade'] ?? '',
      pickupStop: json['pickup_stop'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class IncidentModel {
  // يمكن توسيعها لاحقاً حسب حقول الـ Incident المتاحة
  IncidentModel();

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel();
  }
}
