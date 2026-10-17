import '../../../../services/api_client.dart';
import 'super_admin_model.dart';

class SuperAdminApiService {
  final ApiClient apiClient;

  SuperAdminApiService({required this.apiClient});

  Future<SuperAdminDashboardModel> getDashboard() async {
    final response = await apiClient.dashboard();
    return SuperAdminDashboardModel.fromJson(response);
  }

  Future<List<SchoolModel>> getSchools() async {
    final rawData = await apiClient.list('schools');
    return rawData.map((e) => SchoolModel.fromJson(e)).toList();
  }

  Future<List<SuperAdminRouteModel>> getRoutes() async {
    final rawData = await apiClient.list('routes');
    return rawData.map((e) => SuperAdminRouteModel.fromJson(e)).toList();
  }

  Future<List<dynamic>> getSubscriptions() async {
    try {
      final rawData = await apiClient.list('subscriptions');
      return rawData;
    } catch (_) {
      return [];
    }
  }
}
