import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../config.dart';
import '../../liveTracking/data/parentcubit.dart';
import '../../liveTracking/data/remote_data.dart';
import '../../liveTracking/data/tracking_repo.dart';
import '../../liveTracking/live_tracking.dart';
import '../../models/app_user.dart';
import '../../services/api_client.dart';
import '../../theme/schoolride_theme.dart';
import '../../widgets/feature_page.dart';
import '../data/parent_api_service.dart';
import '../data/parent_cubit.dart';
import '../data/parent_model.dart';
import '../data/parent_repo.dart';

class ParentDashboardScreen extends StatelessWidget {
  final ApiClient api;
  final AppUser user;
  final VoidCallback onLogout;

  const ParentDashboardScreen({
    super.key,
    required this.api,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentCubit(
        repository: ParentRepository(
          apiService: ParentApiService(apiClient: api),
        ),
      )..fetchParentData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parent Portal',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<ParentCubit, ParentState>(
          builder: (context, state) {
            if (state is ParentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ParentError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ParentCubit>().fetchParentData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ParentSuccess) {
              final metrics = state.data.dashboard.metrics;
              final students = state.data.students;
              final trips = state.data.trips;

              final modules = [
                _Module('Live Tracking', '${metrics.activeTrips} active trips',
                    Icons.location_on),
                _Module('My Children', '${students.length} children registered',
                    Icons.child_care),
                _Module('Trips History', '${trips.length} scheduled trips',
                    Icons.directions_bus),
              ];

              return RefreshIndicator(
                onRefresh: () => context.read<ParentCubit>().fetchParentData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          SchoolRideColors.navy,
                          SchoolRideColors.blue
                        ]),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${user.name}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text(
                              'PARENT • Safe Journey, Brighter Tomorrows',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metricBadge('Students',
                                  metrics.students.toString(), Icons.person),
                              _metricBadge('Trips', metrics.trips.toString(),
                                  Icons.route),
                              _metricBadge('Active',
                                  metrics.activeTrips.toString(), Icons.bolt),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: modules.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.13,
                      ),
                      itemBuilder: (context, i) => Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            if (modules[i].title == 'My Children') {
                              // الانتقال لشاشة الأطفال الاحترافية الجديدة
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MyChildrenScreen(students: students),
                                ),
                              );
                            } else if (modules[i].title == 'Trips History') {
                              _showTripsBottomSheet(context, trips);
                            } else if (modules[i].title == 'Live Tracking') {
                              if (trips.isNotEmpty) {
                                final targetTrip = trips.first;
                                final String tokenValue = api.token ?? '';

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (context) => ParentTrackingCubit(
                                        repository: TrackingRepositoryImpl(
                                          remoteDataSource:
                                              TrackingRemoteDataSource(
                                            dio: Dio()
                                              ..options.baseUrl =
                                                  AppConfig.apiBaseUrl,
                                          ),
                                        ),
                                      ),
                                      child: LiveTrackingScreen(
                                        userRole: 'parent',
                                        busNumber: 'BUS-${targetTrip.id}',
                                        tripId: targetTrip.id.toString(),
                                        token: tokenValue,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'No active trips available to track right now.')),
                                );
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FeaturePage(
                                    title: modules[i].title,
                                    subtitle: modules[i].subtitle,
                                    icon: modules[i].icon,
                                    items: [
                                      FeatureItem(
                                          'Overview',
                                          modules[i].subtitle,
                                          Icons.info_outline,
                                          SchoolRideColors.blue),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: (i.isEven
                                          ? SchoolRideColors.orange
                                          : SchoolRideColors.blue)
                                      .withValues(alpha: .14),
                                  child: Icon(modules[i].icon,
                                      color: i.isEven
                                          ? SchoolRideColors.orange
                                          : SchoolRideColors.blue),
                                ),
                                const Spacer(),
                                Text(modules[i].title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(modules[i].subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: SchoolRideColors.muted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _metricBadge(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  void _showTripsBottomSheet(BuildContext context, List<TripModel> trips) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scheduled Trips',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (trips.isEmpty)
              const Text('No trips available.')
            else
              ...trips.map((trip) => ListTile(
                    leading: const Icon(Icons.directions_bus,
                        color: SchoolRideColors.blue),
                    title: Text('Trip Type: ${trip.tripType.toUpperCase()}'),
                    subtitle: Text(
                        'Scheduled: ${trip.scheduledAt}\nStatus: ${trip.status}'),
                    isThreeLine: true,
                  )),
          ],
        ),
      ),
    );
  }
}

// شاشة الأطفال المستقلة بتصميم احترافي
class MyChildrenScreen extends StatelessWidget {
  final List<StudentModel> students;

  const MyChildrenScreen({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My Children',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: students.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.child_care, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No students found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: students.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final student = students[index];
                  final isActive = student.status == 'active';

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: SchoolRideColors.blue
                                    .withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFFEFF6FF),
                              child: Icon(Icons.person,
                                  size: 30, color: SchoolRideColors.blue),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Code: ${student.studentCode} • Grade: ${student.grade}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Stop: ${student.pickupStop}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: SchoolRideColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isActive
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFD97706),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        student.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isActive
                                              ? const Color(0xFF166534)
                                              : const Color(0xFF92400E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Module {
  final String title, subtitle;
  final IconData icon;
  const _Module(this.title, this.subtitle, this.icon);
}
