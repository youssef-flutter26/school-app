import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/app_user.dart';
import '../../services/api_client.dart';
import '../../theme/schoolride_theme.dart';
import '../../widgets/feature_page.dart';
import '../data/super_admin_api_service.dart';
import '../data/super_admin_cubit.dart';
import '../data/super_admin_model.dart';
import '../data/super_admin_repo.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  final ApiClient api;
  final AppUser user;
  final VoidCallback onLogout;

  const SuperAdminDashboardScreen({
    super.key,
    required this.api,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SuperAdminCubit(
        repository: SuperAdminRepository(
          apiService: SuperAdminApiService(apiClient: api),
        ),
      )..fetchSuperAdminData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Super Admin Portal',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                tooltip: 'Sign out',
                onPressed: onLogout,
                icon: const Icon(Icons.logout)),
          ],
        ),
        body: BlocBuilder<SuperAdminCubit, SuperAdminState>(
          builder: (context, state) {
            if (state is SuperAdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SuperAdminError) {
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
                        onPressed: () => context
                            .read<SuperAdminCubit>()
                            .fetchSuperAdminData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is SuperAdminSuccess) {
              final metrics = state.data.dashboard.metrics;
              final schools = state.data.schools;
              final subscriptions = state.data.subscriptions;
              final routes = state.data.routes;

              final modules = [
                _Module(
                    'Platform Overview',
                    '${schools.length} schools, ${metrics.students} students',
                    Icons.dashboard),
                _Module('School Management',
                    '${schools.length} profiles registered', Icons.apartment),
                _Module(
                    'Global Subscriptions',
                    '${subscriptions.length} active plans',
                    Icons.subscriptions),
                _Module(
                    'System Health & Logs',
                    '${routes.length} active routes monitored',
                    Icons.health_and_safety),
              ];

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<SuperAdminCubit>().fetchSuperAdminData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [SchoolRideColors.navy, Colors.purple]),
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
                              'SUPER ADMIN • Full Platform Control & Operations',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metricBadge('Schools', schools.length.toString(),
                                  Icons.apartment),
                              _metricBadge('Students',
                                  metrics.students.toString(), Icons.groups),
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
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            if (modules[i].title == 'School Management') {
                              _showSchoolsBottomSheet(context, schools);
                            } else if (modules[i].title ==
                                'Global Subscriptions') {
                              _showSubscriptionsBottomSheet(
                                  context, subscriptions);
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
                                          Colors.purple),
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
                                  backgroundColor:
                                      Colors.purple.withValues(alpha: .14),
                                  child: Icon(modules[i].icon,
                                      color: Colors.purple),
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

  void _showSchoolsBottomSheet(
      BuildContext context, List<SchoolModel> schools) {
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
            const Text('Managed Schools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (schools.isEmpty)
              const Text('No schools registered.')
            else
              ...schools.map((school) => ListTile(
                    leading: const Icon(Icons.school, color: Colors.purple),
                    title: Text(school.name),
                    subtitle:
                        Text('Code: ${school.code} • Email: ${school.email}'),
                    trailing: Chip(
                      label: Text(school.status,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                      backgroundColor: school.status == 'approved'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionsBottomSheet(
      BuildContext context, List<dynamic> subscriptions) {
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
            const Text('Global Subscriptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (subscriptions.isEmpty)
              const Text('No active subscriptions found.')
            else
              ...subscriptions.map((sub) => ListTile(
                    leading:
                        const Icon(Icons.subscriptions, color: Colors.purple),
                    title: Text('Subscription ID: ${sub['id'] ?? 'N/A'}'),
                    subtitle: Text('Status: ${sub['status'] ?? 'Active'}'),
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
