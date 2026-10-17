import '../../../../services/api_client.dart';
import 'driver_model.dart';

class DriverApiService {
  final ApiClient apiClient;

  DriverApiService({required this.apiClient});

  Future<DriverDashboardModel> getDashboard() async {
    try {
      final response = await apiClient.dashboard();
      final Map<String, dynamic> data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;
      return DriverDashboardModel.fromJson(data);
    } catch (e) {
      print('❌ [DRIVER DASHBOARD ERROR]: $e');
      rethrow;
    }
  }

  // جلب رحلات السائق
  Future<List<DriverTripModel>> getTrips({String? state}) async {
    try {
      final endpoint = state != null ? 'trips?state=$state' : 'trips';
      final rawData = await apiClient.list(endpoint);
      return rawData
          .map((e) => DriverTripModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [DRIVER TRIPS ERROR]: $e');
      return [];
    }
  }

  // جلب الطلاب المرتبطين برحلة معينة باستخدام دالة get الجديدة
  Future<List<DriverStudentModel>> getStudentsForTrip(String tripId) async {
    try {
      final responseData = await apiClient.get('trips/$tripId');

      final dynamic tripData = responseData['data'] ?? responseData;
      List studentsList = [];

      if (tripData is Map) {
        studentsList = tripData['students'] ?? [];
      }

      return studentsList
          .map((e) => DriverStudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [DRIVER TRIP STUDENTS ERROR]: $e');
      return [];
    }
  }

  Future<List<IncidentModel>> getIncidents() async {
    try {
      final rawData = await apiClient.list('incidents');
      return rawData
          .map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [DRIVER INCIDENTS ERROR]: $e');
      return [];
    }
  }
}
