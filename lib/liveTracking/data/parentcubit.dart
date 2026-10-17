import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/notification_service.dart';
import 'tracking_repo.dart';
import 'trip_location_model.dart';

abstract class ParentTrackingState {}

class ParentTrackingInitial extends ParentTrackingState {}

class ParentTrackingLoading extends ParentTrackingState {}

class ParentTrackingLoaded extends ParentTrackingState {
  final TripLocationModel busLocation;
  ParentTrackingLoaded({required this.busLocation});
}

class ParentTrackingError extends ParentTrackingState {
  final String message;
  ParentTrackingError(this.message);
}

class ParentTrackingCubit extends Cubit<ParentTrackingState> {
  final TrackingRepository repository;
  StreamSubscription? _streamSubscription;
  bool _hasTriggeredPreArrival = false;

  // إحداثيات منزل ولي الأمر / المحطة
  final double parentHomeLat = 30.0444;
  final double parentHomeLng = 31.2357;

  ParentTrackingCubit({required this.repository})
      : super(ParentTrackingInitial());

  Future<void> startParentTracking(
      {required String tripId, required String token}) async {
    emit(ParentTrackingLoading());
    try {
      _streamSubscription =
          repository.listenToBusLocation(tripId: tripId, token: token).listen(
        (locationData) {
          // حساب المسافة بين موقع الباص الحالي ومنزل ولي الأمر
          double distanceInMeters = Geolocator.distanceBetween(
            locationData.latitude,
            locationData.longitude,
            parentHomeLat,
            parentHomeLng,
          );

          // 2500 متر تعادل تقريباً 5 دقائق وصول قبل الوصول للمنزل
          if (distanceInMeters <= 2500 && !_hasTriggeredPreArrival) {
            _hasTriggeredPreArrival = true;
            NotificationService.showPreArrivalNotification();
          }

          if (!isClosed) {
            emit(ParentTrackingLoaded(busLocation: locationData));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(ParentTrackingError('Lost connection to bus route tracking'));
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(ParentTrackingError('Connection error: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    repository.dispose();
    return super.close();
  }
}
