import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/notification_service.dart';
import 'tracking_repo.dart';

abstract class DriverTrackingState {}

class DriverTrackingInitial extends DriverTrackingState {}

class DriverTrackingActive extends DriverTrackingState {
  final double lat;
  final double lng;
  DriverTrackingActive(this.lat, this.lng);
}

class DriverTrackingStopped extends DriverTrackingState {}

class DriverTrackingError extends DriverTrackingState {
  final String message;
  DriverTrackingError(this.message);
}

class DriverTrackingCubit extends Cubit<DriverTrackingState> {
  final TrackingRepository repository;
  StreamSubscription<Position>? _positionSubscription;
  bool _hasTriggeredPreArrival = false;

  final double destinationLat = 30.0444;
  final double destinationLng = 31.2357;

  DriverTrackingCubit({required this.repository})
      : super(DriverTrackingInitial());

  Future<void> startTripTracking({
    required String tripId,
    required String token,
  }) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!isClosed) {
            emit(DriverTrackingError('Location permission denied'));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!isClosed) {
          emit(DriverTrackingError(
              'Location permissions are permanently denied'));
        }
        return;
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          if (isClosed) return;

          repository.sendDriverLocation(
            tripId: tripId,
            token: token,
            position: position,
          );

          double distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            destinationLat,
            destinationLng,
          );

          if (distanceInMeters <= 2500 && !_hasTriggeredPreArrival) {
            _hasTriggeredPreArrival = true;
            NotificationService.showPreArrivalNotification();
          }

          if (!isClosed) {
            emit(DriverTrackingActive(position.latitude, position.longitude));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(DriverTrackingError('Location stream error: $error'));
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(DriverTrackingError('Error: ${e.toString()}'));
      }
    }
  }

  Future<void> stopTripTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    repository.dispose();

    if (!isClosed) {
      emit(
          DriverTrackingStopped()); // إرسال حالة الإيقاف لتحديث الواجهة وزر Start فوراً
    }
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    repository.dispose();
    return super.close();
  }
}
