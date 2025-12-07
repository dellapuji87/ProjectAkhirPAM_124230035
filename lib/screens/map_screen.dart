import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class MapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;
  const MapWidget({super.key, required this.latitude, required this.longitude, required this.title});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late final MapController _mapController;
  LatLng? userLocation;
  String jarak = 'Menghitung...';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _cekIzinDanAmbilLokasi();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _cekIzinDanAmbilLokasi() async {

  var status = await Permission.location.status;

  if (status.isDenied) {

    status = await Permission.location.request();
  }

  if (status.isGranted) {
    try {
      Position posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        userLocation = LatLng(posisi.latitude, posisi.longitude);
      });
      _hitungJarak();

      _mapController.move(userLocation!, 15.0);
    } catch (e) {
      setState(() => jarak = 'Gagal ambil lokasi');
    }
  } else if (status.isPermanentlyDenied) {
    setState(() => jarak = 'Izin lokasi ditolak permanen');
    openAppSettings(); 
  } else {
    setState(() => jarak = 'Izin lokasi ditolak');
  }
}

  void _hitungJarak() {
    if (userLocation == null) return;
    final jarakMeter = Geolocator.distanceBetween(
      userLocation!.latitude,
      userLocation!.longitude,
      widget.latitude,
      widget.longitude,
    );
    setState(() {
      jarak = jarakMeter < 1000
          ? '${jarakMeter.toStringAsFixed(0)} m dari lokasi kamu'
          : '${(jarakMeter / 1000).toStringAsFixed(1)} km dari lokasi kamu';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.lokerin',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                    ),
                ],
              ),
            ],
          ),
          
          FutureBuilder(
            future: Future.delayed(Duration.zero, () {
          
              _mapController.move(
                LatLng(widget.latitude, widget.longitude),
                15.0,
              );
            }),
            builder: (_, __) => const SizedBox.shrink(),
          ),

          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk, color: Colors.indigo, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        jarak,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}