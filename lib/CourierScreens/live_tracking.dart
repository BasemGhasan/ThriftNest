import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'dispute_chat.dart';

class LiveTracking extends StatefulWidget {
  const LiveTracking({super.key});

  @override
  State<LiveTracking> createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  static const Color backgroundColor = Color(0xFFEFE9DC);
  static const Color primaryColor = Color(0xFF7BA05B);
  static const Color textColor = Color(0xFF2E3C48);

  late Map<String, dynamic> delivery;
  LatLng? _currentPosition;
  final Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _moveToPosition();
    });
  }

  Future<void> _moveToPosition() async {
    if (_currentPosition == null) return;
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      delivery = Map<String, dynamic>.from(args);
    }
  }

  void completeAction() {
    setState(() {
      if (delivery['status'] == 'pickup') {
        delivery['status'] = 'active';
      } else if (delivery['status'] == 'active') {
        delivery['status'] = 'completed';
      }
    });

    Navigator.pop(context, delivery); // Return updated delivery
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel =
        delivery['status'] == 'pickup' ? 'Picked Up' : 'Completed';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Live Tracking"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🗺️ Real-time map
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 17,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId("courier"),
                            position: _currentPosition!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                            infoWindow:
                                const InfoWindow(title: "Courier Location"),
                          ),
                        },
                        onMapCreated: (controller) {
                          _mapController.complete(controller);
                        },
                      ),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: completeAction,
              child: Text(buttonLabel),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const DisputeChatScreen(orderId: "D003"),
                  ),
                );
              },
              child: const Text("Open Dispute Chat"),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/proof');
              },
              child: const Text("Open Proof of Delivery"),
            ),
          ],
        ),
      ),
    );
  }
}
