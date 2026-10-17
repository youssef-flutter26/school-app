import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart'; // تمت إضافة حزمة Dio لإنشاء المثيل الخاص بالاتصال
import '../../config.dart';
import '../../liveTracking/data/driver_cubit.dart';
import '../../liveTracking/data/remote_data.dart';
import '../../liveTracking/data/tracking_repo.dart';
import '../../liveTracking/live_tracking.dart';
import '../../models/app_user.dart';
import '../../services/api_client.dart';
import '../../theme/schoolride_theme.dart';
import '../../widgets/feature_page.dart';
import '../data/driver_api_sevice.dart';
import '../data/driver_cubit.dart';
import '../data/driver_model.dart';
import '../data/driver_repo.dart';

// استيراد ملفات التتبع الحية

class DriverDashboardScreen extends StatelessWidget {
  final ApiClient api;
  final AppUser user;
  final VoidCallback onLogout;

  const DriverDashboardScreen({
    super.key,
    required this.api,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverCubit(
        repository: DriverRepository(
          apiService: DriverApiService(apiClient: api),
        ),
      )..fetchDriverData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Driver Console',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<DriverCubit, DriverState>(
          builder: (context, state) {
            if (state is DriverLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DriverError) {
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
                            context.read<DriverCubit>().fetchDriverData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DriverSuccess) {
              final metrics = state.data.dashboard.metrics;
              final trips = state.data.trips;
              final students = state.data.students;
              final incidents = state.data.incidents;

              final modules = [
                _Module('Today’s Trip', '${trips.length} scheduled trips',
                    Icons.route),
                _Module('Student Checklist',
                    '${students.length} students assigned', Icons.fact_check),
                _Module('Live Tracking', '${metrics.activeTrips} active routes',
                    Icons.location_on),
                _Module('Incidents', '${incidents.length} reported issues',
                    Icons.warning_amber),
              ];

              return RefreshIndicator(
                onRefresh: () => context.read<DriverCubit>().fetchDriverData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          SchoolRideColors.navy,
                          SchoolRideColors.orange
                        ]),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, ${user.name}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text(
                              'DRIVER • On-Road Safety & Trip Management',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metricBadge('Trips', metrics.trips.toString(),
                                  Icons.route),
                              _metricBadge('Students',
                                  metrics.students.toString(), Icons.person),
                              _metricBadge(
                                  'Incidents',
                                  metrics.openIncidents.toString(),
                                  Icons.report),
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
                            if (modules[i].title == 'Today’s Trip') {
                              _showTripsBottomSheet(context, trips);
                            } else if (modules[i].title ==
                                'Student Checklist') {
                              _showStudentsBottomSheet(context, students);
                            } else if (modules[i].title == 'Live Tracking') {
                              if (trips.isNotEmpty) {
                                final activeTrip = trips.first;
                                final String tokenValue = api.token ?? '';

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (context) => DriverTrackingCubit(
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
                                        userRole: 'driver',
                                        busNumber: 'BUS-${activeTrip.id}',
                                        tripId: activeTrip.id.toString(),
                                        token: tokenValue,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'No active trips available to track.')),
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
                                          SchoolRideColors.orange),
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
                                  backgroundColor: SchoolRideColors.orange
                                      .withValues(alpha: .14),
                                  child: Icon(modules[i].icon,
                                      color: SchoolRideColors.orange),
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

  void _showTripsBottomSheet(
      BuildContext context, List<DriverTripModel> trips) {
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
            const Text('Today\'s Scheduled Trips',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (trips.isEmpty)
              const Text('No trips scheduled.')
            else
              ...trips.map((trip) => ListTile(
                    leading: const Icon(Icons.directions_bus,
                        color: SchoolRideColors.orange),
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

  void _showStudentsBottomSheet(
      BuildContext context, List<DriverStudentModel> students) {
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
            const Text('Student Checklist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (students.isEmpty)
              const Text('No students assigned.')
            else
              ...students.map((student) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student.fullName),
                    subtitle: Text(
                        'Code: ${student.studentCode} • Grade: ${student.grade}\nStop: ${student.pickupStop}'),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(student.status,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                      backgroundColor: student.status == 'active'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  )),
          ],
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
