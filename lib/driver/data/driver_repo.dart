import 'driver_api_sevice.dart';
import 'driver_model.dart';

class DriverRepository {
  final DriverApiService apiService;

  DriverRepository({required this.apiService});

  Future<DriverCompositeData> fetchAllDriverData() async {
    // جلب الداشبورد، كل رحلات السائق المتاحة بدون تقييد بـ active، والحوادث بالتوازي
    final results = await Future.wait([
      apiService.getDashboard(),
      apiService.getTrips(), // تم إزالة state: 'active' لجلب كل الرحلات
      apiService.getIncidents(),
    ]);

    final dashboard = results[0] as DriverDashboardModel;
    final trips = results[1] as List<DriverTripModel>;
    final incidents = results[2] as List<IncidentModel>;

    // جلب الطلاب بناءً على أول رحلة متاحة للتأكد من ظهور البيانات وعدم تصفير الواجهة
    List<DriverStudentModel> students = [];
    if (trips.isNotEmpty) {
      final tripId = trips.first.id.toString();
      students = await apiService.getStudentsForTrip(tripId);
    }

    return DriverCompositeData(
      dashboard: dashboard,
      trips: trips,
      students: students,
      incidents: incidents,
    );
  }
}

class DriverCompositeData {
  final DriverDashboardModel dashboard;
  final List<DriverTripModel> trips;
  final List<DriverStudentModel> students;
  final List<IncidentModel> incidents;

  DriverCompositeData({
    required this.dashboard,
    required this.trips,
    required this.students,
    required this.incidents,
  });
}
