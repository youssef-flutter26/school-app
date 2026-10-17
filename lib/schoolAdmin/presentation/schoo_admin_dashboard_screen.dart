import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../attendance/attendance_screen.dart';
import '../../models/app_user.dart';
import '../../services/api_client.dart';
import '../../theme/schoolride_theme.dart';
import '../../widgets/feature_page.dart';
import '../data/school_admin_api_service.dart';
import '../data/school_admin_cubit.dart';
import '../data/school_admin_model.dart';
import '../data/school_admin_repo.dart';
import 'vehicle_route_form_screen.dart';
import 'students_guardians_screen.dart'; // استيراد شاشة الطلاب وأولياء الأمور الجديدة

class SchoolDashboardScreen extends StatelessWidget {
  final ApiClient api;
  final AppUser user;
  final VoidCallback onLogout;

  const SchoolDashboardScreen({
    super.key,
    required this.api,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(
        repository: AdminRepository(
          apiService: AdminApiService(apiClient: api),
        ),
      )..fetchAdminData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'School Admin Workspace',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: Color(0xFF1E293B)),
            ),
          ],
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminError) {
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
                            context.read<AdminCubit>().fetchAdminData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AdminSuccess) {
              final metrics = state.data.dashboard.metrics;
              final students = state.data.students;
              final vehicles = state.data.vehicles;
              final routes = state.data.routes;
              final trips = state.data.trips;
              final drivers = state.data.drivers;

              final modules = [
                _Module(
                    'Overview',
                    '${metrics.students} students, ${metrics.vehicles} vehicles, ${metrics.trips} trips',
                    Icons.dashboard),
                _Module('Students & Guardians',
                    '${students.length} profiles registered', Icons.groups),
                _Module('Drivers & Attendants',
                    'Staff, documents and assignments', Icons.badge),
                _Module(
                    'Vehicles & Routes',
                    '${vehicles.length} vehicles • ${routes.length} routes',
                    Icons.directions_bus),
                _Module('Trip Management', '${trips.length} scheduled trips',
                    Icons.route),
                _Module('Attendance', 'Pickup and drop-off records',
                    Icons.fact_check),
                _Module('Fees & Subscriptions',
                    'Plans, invoices and payment status', Icons.payments),
                _Module('Reports & Analytics',
                    '${metrics.openIncidents} open incidents', Icons.analytics),
              ];

              return RefreshIndicator(
                onRefresh: () => context.read<AdminCubit>().fetchAdminData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          SchoolRideColors.navy,
                          SchoolRideColors.green
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
                              'SCHOOL ADMIN • Transport Fleet & Student Operations',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metricBadge('Students',
                                  metrics.students.toString(), Icons.groups),
                              _metricBadge(
                                  'Vehicles',
                                  metrics.vehicles.toString(),
                                  Icons.directions_bus),
                              _metricBadge('Trips', metrics.trips.toString(),
                                  Icons.route),
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
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            if (modules[i].title == 'Students & Guardians') {
                              // الانتقال مباشرة لشاشة StudentsGuardiansScreen مع تمرير الكيوبت والطلاب
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentsGuardiansScreen(
                                    adminCubit: context.read<AdminCubit>(),
                                    students: students,
                                  ),
                                ),
                              );
                            } else if (modules[i].title ==
                                'Vehicles & Routes') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VehicleRouteFormScreen(
                                    adminCubit: context.read<AdminCubit>(),
                                    drivers: drivers,
                                    routes: routes,
                                  ),
                                ),
                              );
                            } else if (modules[i].title == 'Trip Management') {
                              _showTripsBottomSheet(context, trips);
                            } else if (modules[i].title == 'Attendance') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttendanceScreen(
                                    apiClient: context
                                        .read<AdminCubit>()
                                        .repository
                                        .apiService
                                        .apiClient,
                                  ),
                                ),
                              );
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
                                          SchoolRideColors.green),
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
                                  backgroundColor: SchoolRideColors.green
                                      .withValues(alpha: .14),
                                  child: Icon(modules[i].icon,
                                      color: SchoolRideColors.green),
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

  void _showTripsBottomSheet(BuildContext context, List<AdminTripModel> trips) {
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
            const Text('Trip Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (trips.isEmpty)
              const Text('No trips available.')
            else
              ...trips.map((trip) => ListTile(
                    leading: const Icon(Icons.alt_route,
                        color: SchoolRideColors.green),
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

class _Module {
  final String title, subtitle;
  final IconData icon;
  const _Module(this.title, this.subtitle, this.icon);
}
