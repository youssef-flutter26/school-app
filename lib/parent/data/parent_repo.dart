import 'parent_api_service.dart';
import 'parent_model.dart';

class ParentRepository {
  final ParentApiService apiService;

  ParentRepository({required this.apiService});

  Future<ParentCompositeData> fetchAllParentData() async {
    final results = await Future.wait([
      apiService.getDashboard(),
      apiService.getStudents(),
      apiService.getTrips(),
    ]);

    return ParentCompositeData(
      dashboard: results[0] as ParentDashboardModel,
      students: results[1] as List<StudentModel>,
      trips: results[2] as List<TripModel>,
    );
  }
}

class ParentCompositeData {
  final ParentDashboardModel dashboard;
  final List<StudentModel> students;
  final List<TripModel> trips;

  ParentCompositeData({
    required this.dashboard,
    required this.students,
    required this.trips,
  });
}
