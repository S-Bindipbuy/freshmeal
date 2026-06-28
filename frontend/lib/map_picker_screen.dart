import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'database_service.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  List<Branch> _branches = [];
  bool _loading = true;
  LatLng? _picked;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final branches = await DatabaseService.getBranches();
      if (mounted) setState(() => _branches = branches);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  LatLng _initialCenter() {
    if (widget.initialLat != null && widget.initialLng != null) {
      return LatLng(widget.initialLat!, widget.initialLng!);
    }
    if (_branches.isNotEmpty) {
      final avgLat = _branches.map((b) => b.lat).reduce((a, b) => a + b) / _branches.length;
      final avgLng = _branches.map((b) => b.lng).reduce((a, b) => a + b) / _branches.length;
      return LatLng(avgLat, avgLng);
    }
    return const LatLng(11.5564, 104.9282);
  }

  void _confirm() {
    if (_picked == null) return;
    Navigator.pop(context, {
      'lat': _picked!.latitude,
      'lng': _picked!.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Your Location'),
        actions: [
          if (_picked != null)
            TextButton(
              onPressed: _confirm,
              child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter(),
                    initialZoom: 12,
                    onTap: (tapPos, latlng) {
                      setState(() => _picked = latlng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.freshmeal.app',
                    ),
                    MarkerLayer(
                      markers: [
                        ..._branches.map(
                          (b) => Marker(
                            point: LatLng(b.lat, b.lng),
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6),
                                ],
                              ),
                              child: const Center(
                                child: Text('B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ),
                        ),
                        if (_picked != null)
                          Marker(
                            point: _picked!,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_picked != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_picked!.latitude.toStringAsFixed(4)}, ${_picked!.longitude.toStringAsFixed(4)}',
                              style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _nearestBranchName() ?? 'No nearby branch',
                              style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _confirm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Confirm Location', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_picked == null)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tap the map to set your location',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String? _nearestBranchName() {
    if (_picked == null || _branches.isEmpty) return null;
    double minDist = double.infinity;
    String? name;
    for (final b in _branches) {
      final d = (b.lat - _picked!.latitude).abs() + (b.lng - _picked!.longitude).abs();
      if (d < minDist) {
        minDist = d;
        name = b.name;
      }
    }
    return name;
  }
}
