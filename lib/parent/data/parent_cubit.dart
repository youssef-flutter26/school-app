import 'package:flutter_bloc/flutter_bloc.dart';

import 'parent_repo.dart';

abstract class ParentState {}

class ParentInitial extends ParentState {}

class ParentLoading extends ParentState {}

class ParentSuccess extends ParentState {
  final ParentCompositeData data;
  ParentSuccess(this.data);
}

class ParentError extends ParentState {
  final String message;
  ParentError(this.message);
}

class ParentCubit extends Cubit<ParentState> {
  final ParentRepository repository;

  ParentCubit({required this.repository}) : super(ParentInitial());

  Future<void> fetchParentData() async {
    emit(ParentLoading());
    try {
      final data = await repository.fetchAllParentData();
      emit(ParentSuccess(data));
    } catch (e) {
      emit(ParentError(e.toString()));
    }
  }
}
