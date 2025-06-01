import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapCard extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;
  final LatLng? initialLocation;

  const GoogleMapCard(
      {super.key, this.onLocationSelected, this.initialLocation});

  @override
  State<GoogleMapCard> createState() => _GoogleMapCardState();
}

class _GoogleMapCardState extends State<GoogleMapCard> {
  GoogleMapController? mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Set initial marker if provided
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Optionally move camera to initial marker
    if (_selectedLocation != null) {
      mapController?.moveCamera(CameraUpdate.newLatLng(_selectedLocation!));
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation ?? _center,
                zoom: 11.0,
              ),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onTap: _onTap,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId('selected_location'),
                        position: _selectedLocation!,
                      ),
                    }
                  : {},
            ),
          ),
        ),
      ),
    );
  }
}

// No changes needed in this Dart file for Google Maps to load tiles.
// Make sure your API key is set up correctly in AndroidManifest.xml and AppDelegate.swift.
