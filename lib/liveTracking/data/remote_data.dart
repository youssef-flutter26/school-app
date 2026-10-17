import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'trip_location_model.dart';

class TrackingRemoteDataSource {
  final Dio dio;
  WebSocketChannel? _parentSocketChannel;
  WebSocketChannel? _driverSocketChannel;

  TrackingRemoteDataSource({required this.dio});

  // جلب تفاصيل الرحلة المبدئية عبر الـ API
  Future<Map<String, dynamic>> getTripDetails({
    required String tripId,
    required String token,
  }) async {
    final response = await dio.get(
      'https://schoolride.signfix.me/api/trips/$tripId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // الاستماع لموقع الحافلة (خاص بولي الأمر)
  Stream<TripLocationModel> connectParentSocket({
    required String tripId,
    required String token,
  }) {
    try {
      final wsUrl = Uri(
        scheme: 'wss',
        host: 'schoolride.signfix.me',
        port: 443,
        path: '/ws/parent/trips/$tripId',
        queryParameters: {'token': token},
      );

      _parentSocketChannel = WebSocketChannel.connect(wsUrl);
    } catch (e) {
      print('❌ [Parent WebSocket Error]: $e');
    }

    if (_parentSocketChannel == null) {
      return const Stream.empty();
    }

    return _parentSocketChannel!.stream.map((event) {
      final jsonMap = jsonDecode(event);
      return TripLocationModel.fromJson(jsonMap);
    }).handleError((error) {
      print('❌ [Parent WebSocket Stream Error]: $error');
    });
  }

  // إرسال موقع السائق الحقيقي عبر الـ WebSocket
  void sendDriverLocation({
    required String tripId,
    required String token,
    required Position position,
  }) {
    try {
      if (_driverSocketChannel == null) {
        final wsUrl = Uri(
          scheme: 'wss',
          host: 'schoolride.signfix.me',
          port: 443,
          path: '/ws/driver/trips/$tripId',
          queryParameters: {'token': token},
        );
        _driverSocketChannel = WebSocketChannel.connect(wsUrl);
      }

      final payload = jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed,
      });

      _driverSocketChannel?.sink.add(payload);
    } catch (e) {
      print('❌ [Driver WebSocket Error]: $e');
    }
  }

  // إغلاق الاتصالات
  void closeSockets() {
    try {
      _parentSocketChannel?.sink.close();
      _driverSocketChannel?.sink.close();
    } catch (e) {
      print('❌ [Close Sockets Error]: $e');
    } finally {
      _parentSocketChannel = null;
      _driverSocketChannel = null;
    }
  }
}
