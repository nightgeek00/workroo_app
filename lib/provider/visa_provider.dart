import 'package:flutter/foundation.dart';

class VisaProvider extends ChangeNotifier {
  int _daysWorked = 0;
  int _totalDays = 88; // 목표 근무일
  int _income = 0;
  int _tax = 0;

  int get daysWorked => _daysWorked;
  int get totalDays => _totalDays;
  int get income => _income;
  int get tax => _tax;

  double get progress => (_daysWorked / _totalDays).clamp(0, 1);

  String get aiFeedback {
    if (_daysWorked >= _totalDays) {
      return "🎉 Second Visa requirement achieved!";
    } else {
      final weeksLeft = (_totalDays - _daysWorked) ~/ 7;
      return "Approximately $weeksLeft weeks to achieve Second Visa.";
    }
  }

  /// PDF 업로드 후 데이터 업데이트
  void updateFromPdf({
    required int days,
    required int incomeVal,
    required int taxVal,
  }) {
    _daysWorked = days;
    _income = incomeVal;
    _tax = taxVal;
    notifyListeners(); // 모든 화면 자동 갱신
  }

  /// 전체 데이터 초기화 (필요 시 사용)
  void reset() {
    _daysWorked = 0;
    _income = 0;
    _tax = 0;
    notifyListeners();
  }
}
