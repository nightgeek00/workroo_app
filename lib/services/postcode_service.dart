import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class PostcodeService {
  Map<String, dynamic>? _data;

  /// JSON 불러오기
  Future<void> loadJson() async {
    final jsonString =
        await rootBundle.loadString('assets/data/visa_postcodes.json');
    _data = json.decode(jsonString);
  }

  /// postcode가 범위 안에 있는지 확인
  bool _inRange(int postcode, List<dynamic> ranges) {
    for (final range in ranges) {
      if (postcode >= range[0] && postcode <= range[1]) {
        return true;
      }
    }
    return false;
  }

  /// postcode가 속하는 모든 카테고리 반환 (옵션2)
  ///
  /// 결과 예시:
  /// ["2nd", "Bushfire", "Disaster"]
  List<String> checkPostcode(int postcode) {
    if (_data == null) {
      throw Exception("JSON data not loaded. Call loadJson() first.");
    }

    List<String> matchedCategories = [];

    // 2nd / 3rd / Bushfire / Disaster 순회
    _data!.forEach((category, states) {
      states.forEach((state, ranges) {
        if (_inRange(postcode, ranges)) {
          matchedCategories.add(category);
        }
      });
    });

    return matchedCategories.isEmpty ? ["Not eligible"] : matchedCategories;
  }
}
