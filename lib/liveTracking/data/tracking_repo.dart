import 'package:geolocator/geolocator.dart';
import 'remote_data.dart';
import 'trip_location_model.dart';

abstract class TrackingRepository {
  Future<Map<String, dynamic>> getTripDetails({
    required String tripId,
    required String token,
  });

  Stream<TripLocationModel> listenToBusLocation({
    required String tripId,
    required String token,
  });

  void sendDriverLocation({
    required String tripId,
    required String token,
    required Position position,
  });

  void dispose();
}

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remoteDataSource;

  TrackingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> getTripDetails({
    required String tripId,
    required String token,
  }) {
    return remoteDataSource.getTripDetails(tripId: tripId, token: token);
  }

  @override
  Stream<TripLocationModel> listenToBusLocation({
    required String tripId,
    required String token,
  }) {
    return remoteDataSource.connectParentSocket(tripId: tripId, token: token);
  }

  @override
  void sendDriverLocation({
    required String tripId,
    required String token,
    required Position position,
  }) {
    remoteDataSource.sendDriverLocation(
      tripId: tripId,
      token: token,
      position: position,
    );
  }

  @override
  void dispose() {
    remoteDataSource.closeSockets();
  }
}
