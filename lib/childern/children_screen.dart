import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_client.dart';
import '../../theme/schoolride_theme.dart';
import '../parent/data/parent_api_service.dart';
import '../parent/data/parent_cubit.dart';
import '../parent/data/parent_repo.dart';

class MyChildrenScreen extends StatelessWidget {
  final ApiClient apiClient;

  const MyChildrenScreen({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentCubit(
        repository: ParentRepository(
          apiService: ParentApiService(apiClient: apiClient),
        ),
      )..fetchParentData(), // لجلب بيانات الـ Dashboard والطلاب مباشرة أول ما الشاشة تفتح
      child: Scaffold(
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
                color: Color(0xFF1E293B), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
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
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
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
              final students = state.data.students;

              if (students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.child_care,
                          size: 64, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'No students found.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isActive = student.status == 'active';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: SchoolRideColors.blue
                                          .withOpacity(0.25),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Color(0xFFEFF6FF),
                                    child: Icon(Icons.person,
                                        size: 28, color: SchoolRideColors.blue),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
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
                                        width: 7,
                                        height: 7,
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
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child:
                                  Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Text(
                                  'Stop: ${student.pickupStop}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
