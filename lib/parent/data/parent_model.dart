class ParentDashboardModel {
  final String role;
  final ParentMetrics metrics;

  ParentDashboardModel({required this.role, required this.metrics});

  factory ParentDashboardModel.fromJson(Map<String, dynamic> json) {
    return ParentDashboardModel(
      role: json['role'] ?? '',
      metrics: ParentMetrics.fromJson(json['metrics'] ?? {}),
    );
  }
}

class ParentMetrics {
  final int students;
  final int vehicles;
  final int trips;
  final int activeTrips;
  final int openIncidents;

  ParentMetrics({
    required this.students,
    required this.vehicles,
    required this.trips,
    required this.activeTrips,
    required this.openIncidents,
  });

  factory ParentMetrics.fromJson(Map<String, dynamic> json) {
    return ParentMetrics(
      students: json['students'] ?? 0,
      vehicles: json['vehicles'] ?? 0,
      trips: json['trips'] ?? 0,
      activeTrips: json['activeTrips'] ?? 0,
      openIncidents: json['openIncidents'] ?? 0,
    );
  }
}

class StudentModel {
  final int id;
  final String studentCode;
  final String fullName;
  final String grade;
  final String pickupStop;
  final String status;

  StudentModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.grade,
    required this.pickupStop,
    required this.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      studentCode: json['studentCode'] ?? json['student_code'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      grade: json['grade'] ?? '',
      pickupStop: json['pickupStop'] ?? json['pickup_stop'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class TripModel {
  final int id;
  final int routeId;
  final int vehicleId;
  final int driverUserId;
  final int attendantUserId;
  final String tripType;
  final String scheduledAt;
  final String status;

  TripModel({
    required this.id,
    required this.routeId,
    required this.vehicleId,
    required this.driverUserId,
    required this.attendantUserId,
    required this.tripType,
    required this.scheduledAt,
    required this.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
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
