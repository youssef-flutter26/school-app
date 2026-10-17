import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';

import 'data/driver_cubit.dart';
import 'data/parentcubit.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String userRole; // 'driver' أو 'parent'
  final String busNumber;
  final String tripId;
  final String token;

  const LiveTrackingScreen({
    Key? key,
    this.userRole = 'driver',
    this.busNumber = 'BUS-402',
    required this.tripId,
    required this.token,
  }) : super(key: key);

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final MapController _mapController = MapController();

  latlong.LatLng _currentBusPosition = const latlong.LatLng(30.0444, 31.2357);
  final latlong.LatLng _destinationPosition =
      const latlong.LatLng(30.0600, 31.2500);

  bool _isFollowingUser = true;
  double _remainingDistanceKm = 0.0;
  int _remainingTimeMins = 0;
  double _busHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateDistanceAndEta(_currentBusPosition);
    if (widget.userRole == 'parent') {
      context.read<ParentTrackingCubit>().startParentTracking(
            tripId: widget.tripId,
            token: widget.token,
          );
    }
  }

  void _calculateDistanceAndEta(latlong.LatLng currentPos) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      _destinationPosition.latitude,
      _destinationPosition.longitude,
    );
    _remainingDistanceKm = distanceInMeters / 1000;
    _remainingTimeMins = ((_remainingDistanceKm / 30) * 60).round();
    if (_remainingTimeMins < 1) _remainingTimeMins = 1;
  }

  void _updatePosition(latlong.LatLng newPos, {double? heading}) {
    setState(() {
      _currentBusPosition = newPos;
      if (heading != null) _busHeading = heading;
      _calculateDistanceAndEta(newPos);
    });

    if (_isFollowingUser) {
      _mapController.move(newPos, 16.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDriver = widget.userRole == 'driver';

    return isDriver
        ? BlocConsumer<DriverTrackingCubit, DriverTrackingState>(
            listener: (context, state) {
              if (state is DriverTrackingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is DriverTrackingActive) {
                final newPos = latlong.LatLng(state.lat, state.lng);
                _updatePosition(newPos);
              }
            },
            builder: (context, state) {
              final bool isTripActive = state is DriverTrackingActive;
              return _buildScreenBody(
                  isDriver: true, isTripActive: isTripActive);
            },
          )
        : BlocConsumer<ParentTrackingCubit, ParentTrackingState>(
            listener: (context, state) {
              if (state is ParentTrackingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is ParentTrackingLoaded) {
                final location = state.busLocation;
                final newPos =
                    latlong.LatLng(location.latitude, location.longitude);
                _updatePosition(newPos, heading: location.heading);
              }
            },
            builder: (context, state) {
              final bool isTripActive = state is ParentTrackingLoaded;
              return _buildScreenBody(
                  isDriver: false, isTripActive: isTripActive);
            },
          );
  }

  Widget _buildScreenBody(
      {required bool isDriver, required bool isTripActive}) {
    return Scaffold(
      body: Stack(
        children: [
          // FlutterMap المحرك الخاص بـ OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentBusPosition,
              initialZoom: 16.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _isFollowingUser) {
                  setState(() {
                    _isFollowingUser = false;
                  });
                }
              },
            ),
            children: [
              // طبقة الخريطة المجانية
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.schoolride',
              ),
              // مسار الرحلة بين الباص والمدرسة
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_currentBusPosition, _destinationPosition],
                    strokeWidth: 5.0,
                    color: const Color(0xFF1E88E5),
                  ),
                ],
              ),
              // علامات الخريطة (الباص والمدرسة)
              MarkerLayer(
                markers: [
                  // ماركر الباص
                  Marker(
                    point: _currentBusPosition,
                    width: 50,
                    height: 50,
                    child: Transform.rotate(
                      angle: (_busHeading * (3.141592653589793 / 180)),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6)
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Color(0xFF1E88E5),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  // ماركر نقطة الوصول (المدرسة)
                  Marker(
                    point: _destinationPosition,
                    width: 45,
                    height: 45,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // الـ Header العريض والزرار العلوي
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black87),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isTripActive
                              ? Colors.green.shade800
                              : Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6)
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: isTripActive
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isTripActive
                                  ? 'LIVE • TRIP ACTIVE'
                                  : 'TRIP PAUSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.my_location,
                            color: _isFollowingUser
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => _isFollowingUser = true);
                            _mapController.move(_currentBusPosition, 16.5);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (isTripActive) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8)
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer,
                              size: 18, color: Color(0xFF1E88E5)),
                          const SizedBox(width: 6),
                          Text(
                            'ETA: ~$_remainingTimeMins mins',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const Text('  •  ',
                              style: TextStyle(color: Colors.grey)),
                          const Icon(Icons.map, size: 18, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            '${_remainingDistanceKm.toStringAsFixed(1)} km left',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // الـ Bottom Sheet السفلي للتحكم
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 15, spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDriver
                                ? 'DRIVER LIVE CONSOLE'
                                : 'PARENT LIVE TRACKING',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bus ID: ${widget.busNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Color(0xFF1E88E5),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (isDriver)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTripActive
                              ? Colors.redAccent
                              : const Color(0xFF1E88E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(
                          isTripActive
                              ? Icons.stop_circle_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        label: Text(
                          isTripActive
                              ? 'End Trip & Stop Sharing'
                              : 'Start Trip & Broadcast Location',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          if (isTripActive) {
                            context
                                .read<DriverTrackingCubit>()
                                .stopTripTracking();
                          } else {
                            context
                                .read<DriverTrackingCubit>()
                                .startTripTracking(
                                  tripId: widget.tripId,
                                  token: widget.token,
                                );
                          }
                        },
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        isTripActive
                            ? 'Receiving bus live location...'
                            : 'Connecting to bus tracking server...',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
