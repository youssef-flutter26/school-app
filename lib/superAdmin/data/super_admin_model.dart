class SuperAdminDashboardModel {
  final String role;
  final SuperAdminMetrics metrics;

  SuperAdminDashboardModel({required this.role, required this.metrics});

  factory SuperAdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return SuperAdminDashboardModel(
      role: json['role'] ?? '',
      metrics: SuperAdminMetrics.fromJson(json['metrics'] ?? {}),
    );
  }
}

class SuperAdminMetrics {
  final int students;
  final int vehicles;
  final int trips;
  final int activeTrips;
  final int openIncidents;

  SuperAdminMetrics({
    required this.students,
    required this.vehicles,
    required this.trips,
    required this.activeTrips,
    required this.openIncidents,
  });

  factory SuperAdminMetrics.fromJson(Map<String, dynamic> json) {
    return SuperAdminMetrics(
      students: json['students'] ?? 0,
      vehicles: json['vehicles'] ?? 0,
      trips: json['trips'] ?? 0,
      activeTrips: json['activeTrips'] ?? 0,
      openIncidents: json['openIncidents'] ?? 0,
    );
  }
}

class SchoolModel {
  final int id;
  final String name;
  final String code;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String createdAt;

  SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class SuperAdminRouteModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String status;

  SuperAdminRouteModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory SuperAdminRouteModel.fromJson(Map<String, dynamic> json) {
    return SuperAdminRouteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
