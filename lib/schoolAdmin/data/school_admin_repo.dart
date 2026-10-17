import 'school_admin_api_service.dart';
import 'school_admin_model.dart';

class AdminRepository {
  final AdminApiService apiService;

  AdminRepository({required this.apiService});

  Future<AdminCompositeData> fetchAllAdminData() async {
    final results = await Future.wait([
      apiService.getDashboard(),
      apiService.getRoutes(),
      apiService.getVehicles(),
      apiService.getTrips(),
      apiService.getStudents(),
      apiService.getDrivers(),
    ]);

    return AdminCompositeData(
      dashboard: results[0] as AdminDashboardModel,
      routes: results[1] as List<AdminRouteModel>,
      vehicles: results[2] as List<AdminVehicleModel>,
      trips: results[3] as List<AdminTripModel>,
      students: results[4] as List<AdminStudentModel>,
      drivers: results[5] as List<AdminDriverModel>,
    );
  }

  Future<void> updateAttendance({
    required int studentId,
    required String tripType,
    required bool isPresent,
  }) async {
    await apiService.updateStudentAttendance(
      studentId: studentId,
      tripType: tripType,
      isPresent: isPresent,
    );
  }

  // إضافة دالة تسجيل الطالب للـ Repository
  Future<void> registerStudent({
    required String fullName,
    required String grade,
    required String pickupStop,
    required String fullAddress,
    required String guardianPhone,
  }) async {
    await apiService.registerStudent(
      fullName: fullName,
      grade: grade,
      pickupStop: pickupStop,
      fullAddress: fullAddress,
      guardianPhone: guardianPhone,
    );
  }
}
