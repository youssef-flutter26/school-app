import 'package:flutter/material.dart';
import 'auth/presentation/login_screen.dart';
import 'driver/presentation/driver_dashboard_screen.dart';
import 'models/app_user.dart';
import 'parent/presentation/parent_dashboard_screen.dart';
import 'schoolAdmin/presentation/schoo_admin_dashboard_screen.dart';
import 'services/api_client.dart';
import 'services/notification_service.dart';
import 'splash/splash_screen.dart'; // تأكد من مسار ملف الـ Splash الصحيح
import 'superAdmin/presentation/super_admin_dashboard_screen.dart';
import 'theme/schoolride_theme.dart';

void main() async {
  // ضمان تهيئة الـ Widgets قبل أي عمليات Async
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة نظام الإشعارات المحلية عند تشغيل التطبيق
  await NotificationService.init();

  runApp(const SchoolRideApp());
}

class SchoolRideApp extends StatefulWidget {
  const SchoolRideApp({super.key});

  @override
  State<SchoolRideApp> createState() => _SchoolRideAppState();
}

class _SchoolRideAppState extends State<SchoolRideApp> {
  final ApiClient api = ApiClient();
  AppUser? user;

  void signedIn(AppUser value) {
    setState(() {
      user = value;
    });
  }

  void signedOut() {
    api.logout();
    setState(() {
      user = null;
    });
  }

  Widget _getHomeScreen() {
    if (user == null) {
      return LoginScreen(api: api, onSignedIn: signedIn);
    }

    final rawRole = user!.role.toLowerCase().trim();

    if (rawRole.contains('parent') || rawRole.contains('guardian')) {
      return ParentDashboardScreen(api: api, user: user!, onLogout: signedOut);
    } else if (rawRole.contains('driver')) {
      return DriverDashboardScreen(api: api, user: user!, onLogout: signedOut);
    } else if (rawRole.contains('school') || rawRole.contains('manager')) {
      return SchoolDashboardScreen(api: api, user: user!, onLogout: signedOut);
    } else if (rawRole.contains('super_admin') ||
        rawRole.contains('platform')) {
      return SuperAdminDashboardScreen(
          api: api, user: user!, onLogout: signedOut);
    } else {
      return ParentDashboardScreen(api: api, user: user!, onLogout: signedOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolRide',
      debugShowCheckedModeBanner: false,
      theme: buildSchoolRideTheme(),
      // جعل شاشة الـ Splash هي أول شاشة تظهر عند فتح التطبيق
      home: SplashScreenWrapper(
        getHomeScreen: _getHomeScreen,
        api: api,
        onSignedIn: signedIn,
      ),
    );
  }
}

// Wrapper لإدارة الانتقال التلقائي من الـ Splash بعد 3 ثوانٍ
class SplashScreenWrapper extends StatefulWidget {
  final Widget Function() getHomeScreen;
  final ApiClient api;
  final Function(AppUser) onSignedIn;

  const SplashScreenWrapper({
    super.key,
    required this.getHomeScreen,
    required this.api,
    required this.onSignedIn,
  });

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // الانتظار لمدة 3 ثوانٍ ثم الانتقال للشاشة التالية
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.getHomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // شاشة الـ Splash التي قمنا بإنشائها
  }
}
