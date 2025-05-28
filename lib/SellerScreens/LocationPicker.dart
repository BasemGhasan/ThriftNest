import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import '../CommonScreens/onboarding.dart';

class LocationPicker extends StatefulWidget {
  final void Function(LatLng coords, String address) onLocationChanged;
  final TextEditingController controller;

  const LocationPicker({
    Key? key,
    required this.onLocationChanged,
    required this.controller,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

/// Runs in a background isolate.
Future<String> _placemarkFromCoordsInIsolate(Map<String, double> args) async {
  final lat = args['lat']!;
  final lng = args['lng']!;
  try {
    final places = await placemarkFromCoordinates(lat, lng);
    if (places.isNotEmpty) {
      final p = places.first;
      return '${p.street}, ${p.locality}';
    }
  } catch (_) {}
  return '';
}

class _LocationPickerState extends State<LocationPicker> {
  bool _loading = true;
  bool _permissionDenied = false;
  LatLng? _currentCoords;
  String _currentAddress = '';
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _fetchPreciseLocation();
  }

  Future<void> _fetchPreciseLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => _permissionDenied = true);
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => _permissionDenied = true);
        return;
      }

      final stopwatch = Stopwatch()..start();
      Position pos;
      do {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );
      } while (pos.accuracy > 10 && stopwatch.elapsed.inSeconds < 10);

      await _updateLocation(LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      setState(() => _permissionDenied = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateLocation(LatLng coords) async {
    _currentCoords = coords;

    // reverse‐geocoding in isolate
    _currentAddress = await compute(
      _placemarkFromCoordsInIsolate,
      {'lat': coords.latitude, 'lng': coords.longitude},
    );

    widget.controller.text = _currentAddress;
    widget.onLocationChanged(coords, _currentAddress);

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(coords));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_permissionDenied) {
      return const Text(
        'Location permission denied. Please enter manually.',
        style: TextStyle(color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_currentCoords != null) ...[
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentCoords!,
                zoom: 17,
              ),
              onMapCreated: (c) => _mapController = c,
              markers: {
                Marker(
                  markerId: const MarkerId('fixed'),
                  position: _currentCoords!,
                  draggable: false,
                ),
              },
              myLocationButtonEnabled: false,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentAddress.isEmpty
                ? 'Your current location'
                : _currentAddress,
            style: const TextStyle(
              color: ThriftNestApp.textColor,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
