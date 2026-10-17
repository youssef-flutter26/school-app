import 'super_admin_api_service.dart';
import 'super_admin_model.dart';

class SuperAdminRepository {
  final SuperAdminApiService apiService;

  SuperAdminRepository({required this.apiService});

  Future<SuperAdminCompositeData> fetchAllSuperAdminData() async {
    // استخدام Future.catchError لمنع انهيار الشاشة في حال حدوث خطأ من السيرفر في أي Endpoint
    final dashboardFuture =
        apiService.getDashboard().catchError((_) => SuperAdminDashboardModel(
              role: 'super_admin',
              metrics: SuperAdminMetrics(
                  students: 0,
                  vehicles: 0,
                  trips: 0,
                  activeTrips: 0,
                  openIncidents: 0),
            ));

    final schoolsFuture =
        apiService.getSchools().catchError((_) => <SchoolModel>[]);
    final routesFuture =
        apiService.getRoutes().catchError((_) => <SuperAdminRouteModel>[]);
    final subscriptionsFuture =
        apiService.getSubscriptions().catchError((_) => <dynamic>[]);

    final results = await Future.wait([
      dashboardFuture,
      schoolsFuture,
      routesFuture,
      subscriptionsFuture,
    ]);

    return SuperAdminCompositeData(
      dashboard: results[0] as SuperAdminDashboardModel,
      schools: results[1] as List<SchoolModel>,
      routes: results[2] as List<SuperAdminRouteModel>,
      subscriptions: results[3] as List<dynamic>,
    );
  }
}

class SuperAdminCompositeData {
  final SuperAdminDashboardModel dashboard;
  final List<SchoolModel> schools;
  final List<SuperAdminRouteModel> routes;
  final List<dynamic> subscriptions;

  SuperAdminCompositeData({
    required this.dashboard,
    required this.schools,
    required this.routes,
    required this.subscriptions,
  });
}
