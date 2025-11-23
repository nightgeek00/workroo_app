import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PostcodeScreen extends StatefulWidget {
  const PostcodeScreen({super.key});

  @override
  State<PostcodeScreen> createState() => _PostcodeScreenState();
}

class _PostcodeScreenState extends State<PostcodeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final MapController _mapController = MapController();

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
    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);
    _loadVisaRegions();
  }

  @override
  void dispose() {
    _pinAnimController.dispose();
    super.dispose();
  }

  /// ✅ JSON 로드
  Future<void> _loadVisaRegions() async {
    final data = await rootBundle.loadString('assets/data/visa_postcodes.json');
    setState(() {
      visaRegions = jsonDecode(data);
    });
  }

  /// ✅ postcode 검사
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

    final eligibility = _getVisaEligibility(code);

    if (eligibility != null) {
      final state = eligibility['state'];
      final type = eligibility['type'];
      final stateCenter = _getStateCenter(state!);

      _mapController.move(stateCenter, 7.0);
      _center = stateCenter;
      _showPinPulse = true;

      switch (type) {
        case "2nd":
          _resultMessage =
              "✅ $code is eligible for 2nd Visa ($state)";
          _messageColor = const Color(0xFF16A34A);
          _bgColor = const Color(0xFFE9FFF0);
          break;
        case "3rd":
          _resultMessage =
              "🟦 $code is eligible for 3rd Visa ($state)";
          _messageColor = const Color(0xFF2563EB);
          _bgColor = const Color(0xFFE0EDFF);
          break;
        default:
          _resultMessage =
              "✅ $code is in a valid visa region ($state)";
          _messageColor = const Color(0xFF3C5BFD);
          _bgColor = const Color(0xFFEFF6FF);
      }
    } else {
      _resultMessage = "❌ $code is NOT eligible for visa extension";
      _messageColor = Colors.red;
      _bgColor = const Color(0xFFFFEAEA);
      _mapController.move(const LatLng(-33.86, 151.21), 5.5);
      _showPinPulse = false;
    }

    setState(() {});
  }

  /// ✅ 비자 판별
  Map<String, String>? _getVisaEligibility(int code) {
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
            return {'type': type, 'state': state};
          }
        }
      }
    }
    return null;
  }

  /// ✅ 주 중심 좌표
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _checkPostcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C5BFD),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Check", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 지도
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: _center, initialZoom: _zoom),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    if (_showPinPulse)
                      MarkerLayer(markers: [
                        Marker(
                          width: 80,
                          height: 80,
                          point: _center,
                          child: ScaleTransition(
                            scale: _pinAnimController,
                            child: const Icon(Icons.location_on,
                                color: Color(0xFF3C5BFD), size: 40),
                          ),
                        ),
                      ])
                    else
                      MarkerLayer(markers: [
                        Marker(
                          width: 60,
                          height: 60,
                          point: _center,
                          child: const Icon(Icons.location_on,
                              color: Color(0xFF3C5BFD), size: 38),
                        ),
                      ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 결과 카드
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
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
