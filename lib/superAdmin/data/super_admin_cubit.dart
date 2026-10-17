import 'package:flutter_bloc/flutter_bloc.dart';
import 'super_admin_repo.dart';

abstract class SuperAdminState {}

class SuperAdminInitial extends SuperAdminState {}

class SuperAdminLoading extends SuperAdminState {}

class SuperAdminSuccess extends SuperAdminState {
  final SuperAdminCompositeData data;
  SuperAdminSuccess(this.data);
}

class SuperAdminError extends SuperAdminState {
  final String message;
  SuperAdminError(this.message);
}

class SuperAdminCubit extends Cubit<SuperAdminState> {
  final SuperAdminRepository repository;

  SuperAdminCubit({required this.repository}) : super(SuperAdminInitial());

  Future<void> fetchSuperAdminData() async {
    emit(SuperAdminLoading());
    try {
      final data = await repository.fetchAllSuperAdminData();
      emit(SuperAdminSuccess(data));
    } catch (e) {
      emit(SuperAdminError(e.toString()));
    }
  }
}
