import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/theme/app_theme.dart';

class LocationPreview extends StatelessWidget {
  const LocationPreview({
    super.key,
    this.loading = false,
    this.latitude,
    this.longitude,
  });

  final bool loading;
  final double? latitude;
  final double? longitude;

  Future<void> _openMaps(BuildContext context) async {
    if (latitude == null || longitude == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Maps n’est pas disponible sur cet appareil.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPosition = latitude != null && longitude != null;
    final coordinates = hasPosition
        ? LatLng(latitude!, longitude!)
        : const LatLng(0, 0);

    return Container(
      height: 164,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EBE7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          if (hasPosition)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: coordinates,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('current-position'),
                  position: coordinates,
                  infoWindow: const InfoWindow(title: 'Votre position'),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            )
          else
            const ColoredBox(color: Color(0xFFE7EBE7)),
          if (loading)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.green,
                ),
              ),
            )
          else if (hasPosition)
            Positioned(
              right: 10,
              bottom: 10,
              child: FilledButton.icon(
                onPressed: () => _openMaps(context),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Google Maps'),
              ),
            ),
        ],
      ),
    );
  }
}
