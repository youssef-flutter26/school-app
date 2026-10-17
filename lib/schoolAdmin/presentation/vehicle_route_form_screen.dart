import 'package:flutter/material.dart';
import '../../theme/schoolride_theme.dart';
import '../data/school_admin_cubit.dart';
import '../data/school_admin_model.dart';

class VehicleRouteFormScreen extends StatefulWidget {
  final AdminCubit adminCubit;
  final List<AdminDriverModel> drivers;
  final List<AdminRouteModel> routes;

  const VehicleRouteFormScreen({
    super.key,
    required this.adminCubit,
    required this.drivers,
    required this.routes,
  });

  @override
  State<VehicleRouteFormScreen> createState() => _VehicleRouteFormScreenState();
}

class _VehicleRouteFormScreenState extends State<VehicleRouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regNoController = TextEditingController();
  final _capacityController = TextEditingController();

  String? _selectedDriverId;
  String? _selectedRouteId;

  @override
  void dispose() {
    _regNoController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // دمج البيانات القادمة من السيرفر مع قيم افتراضية للتأكد من ظهور عناصر دائماً للاختبار
    final driversList = widget.drivers.isNotEmpty
        ? widget.drivers
        : [
            AdminDriverModel(id: 1, fullName: 'Driver Ahmed (Default)'),
            AdminDriverModel(id: 2, fullName: 'Driver Mohamed (Default)'),
          ];

    final routesList = widget.routes.isNotEmpty
        ? widget.routes
        : [
            AdminRouteModel(
                id: 1,
                name: 'Route A - Main District (Default)',
                startTime: '',
                endTime: '',
                status: 'active'),
            AdminRouteModel(
                id: 2,
                name: 'Route B - North Zone (Default)',
                startTime: '',
                endTime: '',
                status: 'active'),
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Register Vehicle & Route',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Vehicle Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SchoolRideColors.navy),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _regNoController,
                decoration: InputDecoration(
                  labelText: 'Registration Number (Plate No)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter registration number'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Vehicle Capacity',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter capacity' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Assignments',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SchoolRideColors.navy),
              ),
              const SizedBox(height: 12),

              // قائمة السائقين (تضمن ظهور عناصر للتجربة حتى لو السيرفر فاضي)
              DropdownButtonFormField<String>(
                value: _selectedDriverId,
                decoration: InputDecoration(
                  labelText: 'Assign Driver',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: driversList.map((driver) {
                  return DropdownMenuItem(
                    value: driver.id.toString(),
                    child: Text(driver.fullName),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDriverId = val),
                validator: (v) => v == null ? 'Please select a driver' : null,
              ),
              const SizedBox(height: 16),

              // قائمة الخطوط (تضمن ظهور عناصر للتجربة حتى لو السيرفر فاضي)
              DropdownButtonFormField<String>(
                value: _selectedRouteId,
                decoration: InputDecoration(
                  labelText: 'Assign Route',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: routesList.map((route) {
                  return DropdownMenuItem(
                    value: route.id.toString(),
                    child: Text(route.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRouteId = val),
                validator: (v) => v == null ? 'Please select a route' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SchoolRideColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.adminCubit.registerVehicle(
                      registrationNo: _regNoController.text.trim(),
                      capacity:
                          int.tryParse(_capacityController.text.trim()) ?? 0,
                      driverId: _selectedDriverId ?? '',
                      routeId: _selectedRouteId ?? '',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vehicle registered successfully!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Save & Register',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
