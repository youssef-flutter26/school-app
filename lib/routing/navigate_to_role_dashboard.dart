import 'package:flutter/material.dart';
import '../driver/presentation/driver_dashboard_screen.dart';
import '../models/app_user.dart';
import '../parent/presentation/parent_dashboard_screen.dart';
import '../schoolAdmin/presentation/schoo_admin_dashboard_screen.dart';
import '../services/api_client.dart';
import '../superAdmin/presentation/super_admin_dashboard_screen.dart';

void navigateToRoleDashboard(
  BuildContext context, {
  required ApiClient api,
  required AppUser user,
  required VoidCallback onLogout,
}) {
  final rawRole = user.role.toLowerCase().trim();

  Widget targetScreen;

  if (rawRole.contains('parent') || rawRole.contains('guardian')) {
    targetScreen =
        ParentDashboardScreen(api: api, user: user, onLogout: onLogout);
  } else if (rawRole.contains('driver')) {
    targetScreen =
        DriverDashboardScreen(api: api, user: user, onLogout: onLogout);
  } else if (rawRole.contains('school') || rawRole.contains('manager')) {
    targetScreen =
        SchoolDashboardScreen(api: api, user: user, onLogout: onLogout);
  } else if (rawRole.contains('super_admin') || rawRole.contains('platform')) {
    targetScreen =
        SuperAdminDashboardScreen(api: api, user: user, onLogout: onLogout);
  } else {
    // Fallback لولي الأمر في حال عدم تطابق الدور
    targetScreen =
        ParentDashboardScreen(api: api, user: user, onLogout: onLogout);
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => targetScreen),
  );
}
