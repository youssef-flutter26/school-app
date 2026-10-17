import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.user, required this.onLogout});
  final ApiClient api;
  final AppUser user;
  final VoidCallback onLogout;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _incidents = [];
  bool _loading = true;
  String? _error;

  String get _roleLabel => switch (widget.user.role) {
    'platform_super_admin' => 'Platform Super Admin',
    'school_admin' => 'School Administrator',
    'transport_manager' => 'Transport Manager',
    'driver' => 'Driver',
    'attendant' => 'Transport Attendant',
    'parent' => 'Parent / Guardian',
    'student' => 'Student',
    'reception' => 'School Reception',
    'accountant' => 'Accountant',
    _ => 'SchoolRide User',
  };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dashboard = await widget.api.dashboard();
      List<Map<String, dynamic>> students = [], vehicles = [], trips = [], incidents = [];
      if (widget.user.role == 'platform_super_admin') {
        // Platform view is intentionally restricted to platform-level resources.
      } else {
        final results = await Future.wait([
          widget.api.list('students'),
          widget.api.list('vehicles'),
          widget.api.list('trips'),
          widget.api.list('incidents'),
        ]);
        students = results[0]; vehicles = results[1]; trips = results[2]; incidents = results[3];
      }
      if (!mounted) return;
      setState(() { _dashboard = dashboard; _students = students; _vehicles = vehicles; _trips = trips; _incidents = incidents; });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load dashboard data. Check API connectivity.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = Map<String, dynamic>.from(_dashboard?['metrics'] as Map? ?? {});
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.directions_bus_rounded), SizedBox(width: 9), Text('SchoolRide', style: TextStyle(fontWeight: FontWeight.w800))]),
        actions: [IconButton(tooltip: 'Refresh', onPressed: _load, icon: const Icon(Icons.refresh)), IconButton(tooltip: 'Sign out', onPressed: widget.onLogout, icon: const Icon(Icons.logout))],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF102A43), Color(0xFF246BCE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, ${widget.user.name.split(' ').first}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              Text(_roleLabel, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(widget.user.email, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              const Row(children: [Icon(Icons.verified_user_outlined, color: Colors.white70, size: 17), SizedBox(width: 7), Expanded(child: Text('Signed in with role-based access', style: TextStyle(color: Colors.white70, fontSize: 12)))]),
            ]),
          ),
          const SizedBox(height: 20),
          const Text("Today's overview", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF102A43))),
          const SizedBox(height: 12),
          if (_loading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator())),
          if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(_error!, style: const TextStyle(color: Colors.red)))),
          if (!_loading && _error == null) _metricsGrid(metrics),
          const SizedBox(height: 22),
          if (widget.user.role == 'parent') _parentCard(),
          if (widget.user.role == 'platform_super_admin') _platformCard(metrics),
          if (_students.isNotEmpty) _section('Students linked to your access', Icons.school_outlined, _students.map((s) => '${s['full_name']} · ${s['grade']} · ${s['pickup_stop'] ?? 'Stop not set'}').toList()),
          if (_vehicles.isNotEmpty) _section('School vehicles', Icons.directions_bus_outlined, _vehicles.map((v) => '${v['display_name']} · ${v['registration_no']} · Capacity ${v['capacity']}').toList()),
          if (_trips.isNotEmpty) _section('Trip schedule and status', Icons.route_outlined, _trips.map((t) => 'Trip #${t['id']} · ${t['trip_type']} · ${t['status']}').toList()),
          if (_incidents.isNotEmpty) _section('Recent incidents', Icons.warning_amber_rounded, _incidents.take(5).map((i) => '${i['incident_type']} · ${i['severity']} · ${i['status']}').toList()),
          const SizedBox(height: 12),
          const Text('MVP note: Live map, background GPS, push notification delivery, OTP, payment collection and handover QR verification require provider/device setup and are not simulated as live features in this starter.', style: TextStyle(color: Color(0xFF61758A), fontSize: 12, height: 1.45)),
        ]),
      ),
    );
  }

  Widget _metricsGrid(Map<String, dynamic> m) {
    if (widget.user.role == 'platform_super_admin') {
      final schools = Map<String, dynamic>.from(m['schools'] as Map? ?? {});
      final subs = Map<String, dynamic>.from(m['subscriptions'] as Map? ?? {});
      return GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.45,
        children: [
          _metric('Schools', '${schools['total'] ?? 0}', Icons.apartment, const Color(0xFF246BCE)),
          _metric('Pending approval', '${schools['pending'] ?? 0}', Icons.pending_actions, const Color(0xFFD97706)),
          _metric('Approved schools', '${schools['approved'] ?? 0}', Icons.verified_outlined, const Color(0xFF138A63)),
          _metric('Active subscriptions', '${subs['active'] ?? 0}', Icons.card_membership, const Color(0xFF7953C8)),
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.45,
      children: [
        _metric('Students', '${m['students'] ?? _students.length}', Icons.school_outlined, const Color(0xFF246BCE)),
        _metric('Vehicles', '${m['vehicles'] ?? _vehicles.length}', Icons.directions_bus_outlined, const Color(0xFF138A63)),
        _metric('Active trips', '${m['activeTrips'] ?? 0}', Icons.route_outlined, const Color(0xFFD97706)),
        _metric('Open incidents', '${m['openIncidents'] ?? 0}', Icons.warning_amber_outlined, const Color(0xFFC24141)),
      ],
    );
  }

  Widget _metric(String title, String value, IconData icon, Color color) => Card(
    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(icon, color: color, size: 23),
      Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Color(0xFF102A43))),
      Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF61758A))),
    ])),
  );

  Widget _parentCard() => Card(
    child: Padding(padding: const EdgeInsets.all(17), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.child_care, color: Color(0xFF246BCE)), SizedBox(width: 8), Text('Child transport', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 10),
      if (_students.isEmpty) const Text('No linked student is available yet. Ask the school to verify and link your account.'),
      ..._students.map((s) => ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.face_rounded)), title: Text(s['full_name']?.toString() ?? 'Student'), subtitle: Text('${s['grade'] ?? ''} · ${s['pickup_stop'] ?? 'Pickup stop pending'}'))),
      const SizedBox(height: 4),
      const Text('Live vehicle tracking becomes available when a real-time trip and authorized GPS provider are configured.', style: TextStyle(fontSize: 12, color: Color(0xFF61758A))),
    ])),
  );

  Widget _platformCard(Map<String, dynamic> metrics) => Card(
    child: Padding(padding: const EdgeInsets.all(17), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Row(children: [Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF246BCE)), SizedBox(width: 8), Text('Platform administration', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))]),
      SizedBox(height: 9),
      Text('School approval APIs and subscription overview are available. This mobile screen is a demo dashboard; full school review, billing configuration and audit tools should be delivered in the dedicated React web admin panel.'),
    ])),
  );

  Widget _section(String title, IconData icon, List<String> items) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: const Color(0xFF246BCE)), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))]),
      const SizedBox(height: 8),
      ...items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.circle, size: 7, color: Color(0xFF138A63)), const SizedBox(width: 9), Expanded(child: Text(item))]))),
    ])),
  );
}
