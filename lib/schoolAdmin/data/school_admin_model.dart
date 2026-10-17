class AdminDashboardModel {
  final String role;
  final AdminMetrics metrics;

  AdminDashboardModel({required this.role, required this.metrics});

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      role: json['role'] ?? '',
      metrics: AdminMetrics.fromJson(json['metrics'] ?? {}),
    );
  }
}

class AdminMetrics {
  final int students;
  final int vehicles;
  final int trips;
  final int activeTrips;
  final int openIncidents;

  AdminMetrics({
    required this.students,
    required this.vehicles,
    required this.trips,
    required this.activeTrips,
    required this.openIncidents,
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    return AdminMetrics(
      students: json['students'] ?? 0,
      vehicles: json['vehicles'] ?? 0,
      trips: json['trips'] ?? 0,
      activeTrips: json['activeTrips'] ?? 0,
      openIncidents: json['openIncidents'] ?? 0,
    );
  }
}

class AdminRouteModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String status;

  AdminRouteModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory AdminRouteModel.fromJson(Map<String, dynamic> json) {
    return AdminRouteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class AdminVehicleModel {
  final int id;
  final String registrationNo;
  final String displayName;
  final int capacity;
  final String status;

  AdminVehicleModel({
    required this.id,
    required this.registrationNo,
    required this.displayName,
    required this.capacity,
    required this.status,
  });

  factory AdminVehicleModel.fromJson(Map<String, dynamic> json) {
    return AdminVehicleModel(
      id: json['id'] ?? 0,
      registrationNo: json['registration_no'] ?? '',
      displayName: json['display_name'] ?? '',
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class AdminTripModel {
  final int id;
  final int routeId;
  final int vehicleId;
  final int driverUserId;
  final int attendantUserId;
  final String tripType;
  final String scheduledAt;
  final String status;

  AdminTripModel({
    required this.id,
    required this.routeId,
    required this.vehicleId,
    required this.driverUserId,
    required this.attendantUserId,
    required this.tripType,
    required this.scheduledAt,
    required this.status,
  });

  factory AdminTripModel.fromJson(Map<String, dynamic> json) {
    return AdminTripModel(
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

class AdminStudentModel {
  final int id;
  final String studentCode;
  final String fullName;
  final String grade;
  final String pickupStop;
  final String fullAddress;
  final String guardianPhone;
  final String status;

  AdminStudentModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.grade,
    required this.pickupStop,
    required this.fullAddress,
    required this.guardianPhone,
    required this.status,
  });

  factory AdminStudentModel.fromJson(Map<String, dynamic> json) {
    return AdminStudentModel(
      id: json['id'] ?? 0,
      studentCode: json['student_code'] ?? '',
      fullName: json['full_name'] ?? '',
      grade: json['grade'] ?? '',
      pickupStop: json['pickup_stop'] ?? '',
      fullAddress: json['full_address'] ?? json['address'] ?? '',
      guardianPhone: json['guardian_phone'] ?? json['phone'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'grade': grade,
      'pickup_stop': pickupStop,
      'full_address': fullAddress,
      'guardian_phone': guardianPhone,
    };
  }
}

class AdminDriverModel {
  final int id;
  final String fullName;

  AdminDriverModel({required this.id, required this.fullName});

  factory AdminDriverModel.fromJson(Map<String, dynamic> json) {
    return AdminDriverModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? json['name'] ?? '',
    );
  }
}

class AdminCompositeData {
  final AdminDashboardModel dashboard;
  final List<AdminRouteModel> routes;
  final List<AdminVehicleModel> vehicles;
  final List<AdminTripModel> trips;
  final List<AdminStudentModel> students;
  final List<AdminDriverModel> drivers;

  AdminCompositeData({
    required this.dashboard,
    required this.routes,
    required this.vehicles,
    required this.trips,
    required this.students,
    required this.drivers,
  });
}
