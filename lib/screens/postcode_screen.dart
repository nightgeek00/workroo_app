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

  /// postcode → { state, lat, lng, eligibility }
  Map<String, dynamic> postcodeLocations = {};

  /// UI 상태
  String _resultMessage = "Enter a postcode to check visa eligibility";
  Color _messageColor = Colors.black;
  Color _bgColor = Colors.white;

  /// 지도 상태
  LatLng _center = const LatLng(-25.27, 133.77); // Australia center
  double _zoom = 4.0;

  bool _showPinPulse = false;
  late AnimationController _pinAnimController;

  /// 로딩/처리 상태
  bool _isLoaded = false;
  bool _isChecking = false;

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

    _initData();
  }

  /// JSON 데이터 로딩 (최적화됨)
  Future<void> _initData() async {
    try {
      final data = await rootBundle
          .loadString('assets/data/merged_postcodes_2nd_3rd.json'); // ← 경로 적용됨!
      final decoded = jsonDecode(data) as Map<String, dynamic>;

      setState(() {
        postcodeLocations = decoded;
        _isLoaded = true;
      });
    } catch (e) {
      debugPrint("❌ Failed to load postcode data: $e");
      setState(() {
        _resultMessage = "Failed to load postcode data.";
        _messageColor = Colors.red;
        _bgColor = const Color(0xFFFFEAEA);
      });
    }
  }

  @override
  void dispose() {
    _pinAnimController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// postcode 기반 eligibility 체크 함수(최적화)
  List<Map<String, String>> _getVisaEligibilityMulti(int code) {
    final codeStr = code.toString();

    if (!postcodeLocations.containsKey(codeStr)) {
      return [];
    }

    final entry = postcodeLocations[codeStr];

    final String state = entry["state"];
    final List<dynamic> eligibility = entry["eligibility"];

    return eligibility
        .map((e) => {"type": e.toString(), "state": state})
        .toList();
  }

  /// 지도 애니메이션 최적화 호출
  void _animateMapTo(LatLng dest, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animatedMapController.animateTo(dest: dest, zoom: zoom);
    });
  }

  void _checkPostcode() {
    if (!_isLoaded || _isChecking) return;

    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final code = int.tryParse(input);
    if (code == null) {
      _setMessage("⚠️ Invalid postcode", Colors.orange, const Color(0xFFFFF6E5));
      setState(() => _showPinPulse = false);
      return;
    }

    setState(() => _isChecking = true);

    final codeStr = code.toString();
    final results = _getVisaEligibilityMulti(code);

    if (results.isNotEmpty) {
      _resultMessage = results
          .map((e) => "• ${e['type']} Visa Eligible (${e['state']})")
          .join("\n");

      _messageColor = const Color(0xFF16A34A);
      _bgColor = const Color(0xFFE3FFE9);

      // 좌표 존재
      if (postcodeLocations.containsKey(codeStr)) {
        final loc = postcodeLocations[codeStr];

        final LatLng point =
            LatLng((loc["lat"] as num).toDouble(), (loc["lng"] as num).toDouble());

        _animateMapTo(point, 16.0);

        setState(() {
          _center = point;
          _zoom = 16.0;
          _showPinPulse = true;
        });
      }
      // 좌표 없으면 state 중심
      else {
        final state = results.first["state"]!;
        final stateCenter = _getStateCenter(state);

        _animateMapTo(stateCenter, 10.0);

        setState(() {
          _center = stateCenter;
          _zoom = 10.0;
          _showPinPulse = true;
        });
      }
    } else {
      // 비자 불가능 지역
      _setMessage(
        "❌ $code is NOT eligible for visa extension",
        Colors.red,
        const Color(0xFFFFEAEA),
      );

      final fallback = const LatLng(-33.86, 151.21);

      _animateMapTo(fallback, 5.5);

      setState(() {
        _center = fallback;
        _zoom = 5.5;
        _showPinPulse = false;
      });
    }

    setState(() => _isChecking = false);
  }

  void _setMessage(String msg, Color textColor, Color bgColor) {
    _resultMessage = msg;
    _messageColor = textColor;
    _bgColor = bgColor;
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
    if (!_isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F8FD),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                    onSubmitted: (value) => _checkPostcode(),
                    decoration: InputDecoration(
                      hintText: "Enter postcode (e.g. 4470)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isChecking ? null : _checkPostcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C5BFD),
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Check",
                          style: TextStyle(color: Colors.white),
                        ),
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
                    keepAlive: true,
                    minZoom: 3,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: _showPinPulse ? 80 : 60,
                          height: _showPinPulse ? 80 : 60,
                          point: _center,
                          child: _showPinPulse
                              ? ScaleTransition(
                                  scale: _pinAnimController,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF3C5BFD),
                                    size: 40,
                                  ),
                                )
                              : const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF3C5BFD),
                                  size: 38,
                                ),
                        ),
                      ],
                    ),
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
