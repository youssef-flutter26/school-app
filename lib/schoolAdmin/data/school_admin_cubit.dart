import 'package:flutter_bloc/flutter_bloc.dart';
import 'school_admin_repo.dart';
import 'school_admin_model.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminSuccess extends AdminState {
  final AdminCompositeData data;
  AdminSuccess(this.data);
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository repository;

  AdminCubit({required this.repository}) : super(AdminInitial());

  Future<void> fetchAdminData() async {
    emit(AdminLoading());
    try {
      final data = await repository.fetchAllAdminData();
      emit(AdminSuccess(data));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> markAttendance({
    required int studentId,
    required String tripType,
    required bool isPresent,
  }) async {
    try {
      await repository.updateAttendance(
        studentId: studentId,
        tripType: tripType,
        isPresent: isPresent,
      );
    } catch (e) {
      // التعامل مع الأخطاء إن وجدت
    }
  }

  Future<void> registerVehicle({
    required String registrationNo,
    required int capacity,
    required String driverId,
    required String routeId,
  }) async {
    try {
      await repository.apiService.registerVehicleWithRouteAndDriver(
        registrationNo: registrationNo,
        capacity: capacity,
        driverId: driverId,
        routeId: routeId,
      );
      fetchAdminData();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  // إضافة دالة تسجيل الطالب في الـ Cubit وتحديث البيانات تلقائياً
  Future<void> registerStudent({
    required String fullName,
    required String grade,
    required String pickupStop,
    required String fullAddress,
    required String guardianPhone,
  }) async {
    try {
      await repository.registerStudent(
        fullName: fullName,
        grade: grade,
        pickupStop: pickupStop,
        fullAddress: fullAddress,
        guardianPhone: guardianPhone,
      );
      // جلب وتحديث البيانات فوراً بعد الإضافة الناجحة
      fetchAdminData();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
