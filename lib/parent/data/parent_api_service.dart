import '../../services/api_client.dart';
import 'parent_model.dart';

class ParentApiService {
  final ApiClient apiClient;

  ParentApiService({required this.apiClient});

  // جلب الـ dashboard مع معالجة آمنة لصلاحيات السيرفر
  Future<ParentDashboardModel> getDashboard() async {
    try {
      print('🛡️ [API TOKEN CHECK]: ${apiClient.token}');

      final response = await apiClient.dashboard();

      final Map<String, dynamic> data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;

      return ParentDashboardModel.fromJson(data);
    } catch (e) {
      print('❌ [DASHBOARD ERROR]: $e');
      return ParentDashboardModel(
        role: 'parent',
        metrics: ParentMetrics(
          students: 0,
          vehicles: 0,
          trips: 0,
          activeTrips: 0,
          openIncidents: 0,
        ),
      );
    }
  }

  // جلب قائمة الطلاب مع التأكد من إرسال التوكن والصلاحيات
  Future<List<StudentModel>> getStudents() async {
    try {
      print('🛡️ [STUDENTS TOKEN CHECK]: ${apiClient.token}');
      // تمرير الهيدر أو استخدام الطريقة التي تدعم التوكن في الـ ApiClient الخاص بك
      final rawData = await apiClient.list('students');
      return rawData.map((e) => StudentModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ [STUDENTS ERROR]: $e');
      return [];
    }
  }

  // جلب قائمة الرحلات مع التأكد من إرسال التوكن والصلاحيات
  Future<List<TripModel>> getTrips() async {
    try {
      print('🛡️ [TRIPS TOKEN CHECK]: ${apiClient.token}');
      // تمرير الهيدر أو استخدام الطريقة التي تدعم التوكن في الـ ApiClient الخاص بك
      final rawData = await apiClient.list('trips');
      return rawData.map((e) => TripModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ [TRIPS ERROR]: $e');
      return [];
    }
  }
}
