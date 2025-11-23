import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

class PostcodeScreen extends StatefulWidget {
  const PostcodeScreen({super.key});

  @override
  State<PostcodeScreen> createState() => _PostcodeScreenState();
}

class _PostcodeScreenState extends State<PostcodeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final MapController _mapController = MapController();
  late final AnimatedMapController _animatedMapController;

  Map<String, dynamic> visaRegions = {};
  String _resultMessage = "Enter a postcode to check visa eligibility";
  Color _messageColor = Colors.black;
  Color _bgColor = Colors.white;
  LatLng _center = const LatLng(-25.27, 133.77);
  double _zoom = 4.3;

  bool _showPinPulse = false;
  late AnimationController _pinAnimController;

  @override
  void initState() {
    super.initState();

    _animatedMapController = AnimatedMapController(
      vsync: this,
      mapController: _mapController,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
    );

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _loadVisaRegions();
  }

  @override
  void dispose() {
    _pinAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadVisaRegions() async {
    final data = await rootBundle.loadString('assets/data/visa_postcodes.json');
    setState(() {
      visaRegions = jsonDecode(data);
    });
  }

  List<Map<String, String>> _getVisaEligibilityMulti(int code) {
    List<Map<String, String>> results = [];

    for (final entry in visaRegions.entries) {
      final type = entry.key;
      final states = Map<String, dynamic>.from(entry.value);

      for (final stateEntry in states.entries) {
        final state = stateEntry.key;
        final ranges = List<List<int>>.from(
          (stateEntry.value as List).map((e) => List<int>.from(e)),
        );

        for (final range in ranges) {
          if (code >= range[0] && code <= range[1]) {
            results.add({'type': type, 'state': state});
          }
        }
      }
    }

    return results;
  }

  void _checkPostcode() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final code = int.tryParse(input);
    if (code == null) {
      setState(() {
        _resultMessage = "⚠️ Invalid postcode";
        _messageColor = Colors.orange;
        _bgColor = const Color(0xFFFFF6E5);
        _showPinPulse = false;
      });
      return;
    }

    final results = _getVisaEligibilityMulti(code);

    if (results.isNotEmpty) {
      _resultMessage = results
          .map((e) => "• ${e['type']} Visa Eligible (${e['state']})")
          .join("\n");

      _messageColor = const Color(0xFF16A34A);
      _bgColor = const Color(0xFFE3FFE9);

      final firstState = results.first['state']!;
      final stateCenter = _getStateCenter(firstState);

      _animatedMapController.animateTo(
        dest: stateCenter,
        zoom: 8.5,
      );

      _center = stateCenter;
      _zoom = 8.5;
      _showPinPulse = true;
    } else {
      _resultMessage = "❌ $code is NOT eligible for visa extension";
      _messageColor = Colors.red;
      _bgColor = const Color(0xFFFFEAEA);

      _animatedMapController.animateTo(
        dest: const LatLng(-33.86, 151.21),
        zoom: 5.5,
      );

      _center = const LatLng(-33.86, 151.21);
      _zoom = 5.5;
      _showPinPulse = false;
    }

    setState(() {});
  }

  LatLng _getStateCenter(String state) {
    switch (state) {
      case "Queensland":
        return const LatLng(-23.7, 150.3);
      case "New South Wales":
        return const LatLng(-32.0, 147.0);
      case "Victoria":
        return const LatLng(-37.0, 144.0);
      case "South Australia":
        return const LatLng(-30.0, 135.0);
      case "Western Australia":
        return const LatLng(-26.0, 121.0);
      case "Tasmania":
        return const LatLng(-42.0, 147.0);
      case "Northern Territory":
        return const LatLng(-19.0, 133.0);
      default:
        return const LatLng(-25.27, 133.77);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text("Postcode Checker"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter postcode (e.g. 4470)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _checkPostcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C5BFD),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Check",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _zoom,
                    minZoom: 3,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        width: _showPinPulse ? 80 : 60,
                        height: _showPinPulse ? 80 : 60,
                        point: _center,
                        child: _showPinPulse
                            ? ScaleTransition(
                                scale: _pinAnimController,
                                child: const Icon(Icons.location_on,
                                    color: Color(0xFF3C5BFD), size: 40),
                              )
                            : const Icon(Icons.location_on,
                                color: Color(0xFF3C5BFD), size: 38),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                _resultMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _messageColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
