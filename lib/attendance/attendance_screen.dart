import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_client.dart';
import '../../theme/schoolride_theme.dart';

import '../schoolAdmin/data/school_admin_api_service.dart';
import '../schoolAdmin/data/school_admin_cubit.dart';
import '../schoolAdmin/data/school_admin_model.dart';
import '../schoolAdmin/data/school_admin_repo.dart';

class AttendanceScreen extends StatelessWidget {
  final ApiClient apiClient;

  const AttendanceScreen({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(
        repository: AdminRepository(
          apiService: AdminApiService(
            apiClient: apiClient,
          ),
        ),
      )..fetchAdminData(),
      child: const AttendanceView(),
    );
  }
}

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGrade = 'All';

  final List<String> _grades = [
    'All',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SchoolRideColors.navy,
        centerTitle: true,
        title: const Text(
          'Attendance & Tracking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: SchoolRideColors.green,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny_rounded), text: 'Morning Pickup'),
            Tab(icon: Icon(Icons.nightlight_round), text: 'Evening Drop-off'),
          ],
        ),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (state is AdminSuccess) {
            final allStudents = state.data.students;

            final filteredList = _selectedGrade == 'All'
                ? allStudents
                : allStudents.where((s) => s.grade == _selectedGrade).toList();

            return Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _grades.length,
                    itemBuilder: (context, index) {
                      final grade = _grades[index];
                      final isSelected = grade == _selectedGrade;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(grade),
                          selected: isSelected,
                          selectedColor:
                              SchoolRideColors.green.withValues(alpha: 0.2),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? SchoolRideColors.green
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedGrade = grade;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStudentsListView(filteredList, 'morning_pickup'),
                      _buildStudentsListView(filteredList, 'evening_drop'),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStudentsListView(
      List<AdminStudentModel> students, String tripType) {
    if (students.isEmpty) {
      return const Center(
        child: Text(
          'No students found in this class.',
          style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = students[index];
        bool isPresent = student.status.toLowerCase() != 'absent';

        return StatefulBuilder(
          builder: (context, setStateItem) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        SchoolRideColors.green.withValues(alpha: 0.15),
                    child:
                        const Icon(Icons.person, color: SchoolRideColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Code: ${student.studentCode} • Grade: ${student.grade}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          'Stop: ${student.pickupStop}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch.adaptive(
                        value: isPresent,
                        activeColor: SchoolRideColors.green,
                        onChanged: (val) {
                          setStateItem(() {
                            isPresent = val;
                          });

                          context.read<AdminCubit>().markAttendance(
                                studentId: student.id,
                                tripType: tripType,
                                isPresent: val,
                              );
                        },
                      ),
                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isPresent ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
