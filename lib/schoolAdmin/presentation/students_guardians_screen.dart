import 'package:flutter/material.dart';
import '../../theme/schoolride_theme.dart';
import '../data/school_admin_cubit.dart';
import '../data/school_admin_model.dart';

class StudentsGuardiansScreen extends StatefulWidget {
  final AdminCubit adminCubit;
  final List<AdminStudentModel>? students;

  const StudentsGuardiansScreen({
    super.key,
    required this.adminCubit,
    this.students,
  });

  @override
  State<StudentsGuardiansScreen> createState() =>
      _StudentsGuardiansScreenState();
}

class _StudentsGuardiansScreenState extends State<StudentsGuardiansScreen> {
  late List<AdminStudentModel> _localStudents;

  @override
  void initState() {
    super.initState();
    _localStudents = widget.students ?? [];
  }

  void _showAddStudentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final gradeController = TextEditingController();
    final stopController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Register New Student',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SchoolRideColors.navy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Student Full Name',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter student name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Guardian Mobile Number',
                    hintText: 'e.g. 010xxxxxxxx',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 10) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Full Address (Student / Parent)',
                    hintText: 'City, Street, Building No, Landmark',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter full address'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: gradeController,
                        decoration: InputDecoration(
                          labelText: 'Grade',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: stopController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Stop',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SchoolRideColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        // استدعاء السيرفر والكيوبت لإرسال البيانات الحقيقية
                        await widget.adminCubit.registerStudent(
                          fullName: nameController.text.trim(),
                          grade: gradeController.text.trim(),
                          pickupStop: stopController.text.trim(),
                          fullAddress: addressController.text.trim(),
                          guardianPhone: phoneController.text.trim(),
                        );

                        // إنشاء العنصر محلياً وعرضه فوراً في القائمة
                        final newStudent = AdminStudentModel(
                          id: DateTime.now().millisecondsSinceEpoch,
                          studentCode:
                              'ST-${DateTime.now().second}${DateTime.now().millisecond}',
                          fullName: nameController.text.trim(),
                          grade: gradeController.text.trim(),
                          pickupStop: stopController.text.trim(),
                          fullAddress: addressController.text.trim(),
                          guardianPhone: phoneController.text.trim(),
                          status: 'active',
                        );

                        setState(() {
                          _localStudents.insert(0, newStudent);
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Student registered & sent to server successfully!')),
                        );
                      }
                    },
                    child: const Text(
                      'Save Student Profile',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Students & Guardians',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: _localStudents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No students registered yet',
                    style: TextStyle(
                        fontSize: 16,
                        color: SchoolRideColors.muted,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _localStudents.length,
              itemBuilder: (context, index) {
                final student = _localStudents[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor:
                          SchoolRideColors.green.withValues(alpha: 0.15),
                      child: const Icon(Icons.person,
                          color: SchoolRideColors.green),
                    ),
                    title: Text(
                      student.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B)),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Code: ${student.studentCode} • Grade: ${student.grade}\nStop: ${student.pickupStop}\nAddress: ${student.fullAddress}',
                        style: const TextStyle(
                            color: SchoolRideColors.muted, fontSize: 13),
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: student.status == 'active'
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        student.status,
                        style: TextStyle(
                          color: student.status == 'active'
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SchoolRideColors.green,
        onPressed: () => _showAddStudentDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Student',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
