import 'package:flutter_bloc/flutter_bloc.dart';
import 'driver_repo.dart';

abstract class DriverState {}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverSuccess extends DriverState {
  final DriverCompositeData data;
  DriverSuccess(this.data);
}

class DriverError extends DriverState {
  final String message;
  DriverError(this.message);
}

class DriverCubit extends Cubit<DriverState> {
  final DriverRepository repository;

  DriverCubit({required this.repository}) : super(DriverInitial());

  Future<void> fetchDriverData() async {
    emit(DriverLoading());
    try {
      final data = await repository.fetchAllDriverData();
      emit(DriverSuccess(data));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }
}
