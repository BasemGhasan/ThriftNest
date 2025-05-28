import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../CommonScreens/onboarding.dart';

// A widget that requests location permission, shows a Google Map with a draggable
// pin at the user's current location, and reports back the selected coords & address.
class LocationPicker extends StatefulWidget {
  // Called whenever the selected location changes (initial or drag).
  final void Function(LatLng coords, String address) onLocationChanged;

  const LocationPicker({
    Key? key,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _currentCoords;
  String _currentAddress = '';
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /// Requests permission and fetches current position.
  Future<void> _initLocation() async {
    // Check service
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _permissionDenied = true);
      return;
    }
    // Request permission
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      setState(() => _permissionDenied = true);
      return;
    }
    // Get position
    final pos = await Geolocator.getCurrentPosition();
    _updateLocation(LatLng(pos.latitude, pos.longitude));
  }

  /// Updates coords, reverse-geocodes, and notifies parent.
  Future<void> _updateLocation(LatLng coords) async {
    _currentCoords = coords;
    // Reverse geocode
    final places = await placemarkFromCoordinates(coords.latitude, coords.longitude);
    if (places.isNotEmpty) {
      final p = places.first;
      _currentAddress = '${p.street}, ${p.locality}';
    }
    widget.onLocationChanged(coords, _currentAddress);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // If no permission, fallback to manual entry
    if (_permissionDenied) {
      return TextFormField(
        decoration: const InputDecoration(labelText: 'Location'),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      );
    }
    // While fetching
    if (_currentCoords == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // Show map + address
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCoords!,
              zoom: 15,
            ),
            onMapCreated: (ctrl) => _mapController = ctrl,
            onCameraMove: (pos) => _updateLocation(pos.target),
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _currentCoords!,
                draggable: true,
                onDragEnd: (newPos) => _updateLocation(newPos),
              ),
            },
            myLocationButtonEnabled: false,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentAddress,
          style: const TextStyle(
            color: ThriftNestApp.textColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}