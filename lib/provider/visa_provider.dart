import 'package:flutter/foundation.dart';

class PayslipEntry {
  final String id;        // 고유 ID (화면에서 삭제할 때 사용)
  final String fileName;  // 파일명 표시용
  final int days;
  final int income;
  final int tax;
  final int superAmount;

  PayslipEntry({
    required this.id,
    required this.fileName,
    required this.days,
    required this.income,
    required this.tax,
    required this.superAmount,
  });
}

class VisaProvider extends ChangeNotifier {
  // 2nd 또는 3rd
  String _visaType = '2nd'; // '2nd' or '3rd'
  int _targetDays = 88;     // 2nd: 88, 3rd: 179

  final List<PayslipEntry> _payslips = [];

  // ───── 공개 getter들 ─────
  String get visaType => _visaType;
  int get totalDays => _targetDays;

  List<PayslipEntry> get payslips => List.unmodifiable(_payslips);

  int get daysWorked =>
      _payslips.fold(0, (sum, p) => sum + p.days);

  int get income =>
      _payslips.fold(0, (sum, p) => sum + p.income);

  int get tax =>
      _payslips.fold(0, (sum, p) => sum + p.tax);

  int get superannuation =>
      _payslips.fold(0, (sum, p) => sum + p.superAmount);

  int get netPay => income - tax;

  double get progress =>
      (daysWorked / (_targetDays == 0 ? 1 : _targetDays))
          .clamp(0, 1)
          .toDouble();

  String get aiFeedback {
    if (daysWorked >= _targetDays) {
      final visaLabel =
          _visaType == '3rd' ? 'Third Visa' : 'Second Visa';
      return "🎉 $visaLabel requirement achieved!";
    } else {
      final remaining = _targetDays - daysWorked;
      final weeksLeft = (remaining / 7).ceil();
      final visaLabel =
          _visaType == '3rd' ? 'Third Visa' : 'Second Visa';
      return "Approximately $weeksLeft weeks to achieve $visaLabel.";
    }
  }

  // ───── 비자 타입(2nd / 3rd) 변경 ─────
  void setVisaType(String type) {
    if (type != '2nd' && type != '3rd') return;
    _visaType = type;
    _targetDays = (type == '3rd') ? 179 : 88;
    notifyListeners();
  }

  // ───── PDF 하나 업로드 시 데이터 추가 ─────
  void updateFromPdf({
    required String id,
    required String fileName,
    required int days,
    required int incomeVal,
    required int taxVal,
    int superVal = 0,
  }) {
    // 같은 id가 이미 있으면 덮어쓰기
    _payslips.removeWhere((p) => p.id == id);

    _payslips.add(
      PayslipEntry(
        id: id,
        fileName: fileName,
        days: days,
        income: incomeVal,
        tax: taxVal,
        superAmount: superVal,
      ),
    );

    notifyListeners();
  }

  // ───── 특정 payslip 삭제 ─────
  void removePayslip(String id) {
    _payslips.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ───── 전체 초기화 ─────
  void reset() {
    _payslips.clear();
    _visaType = '2nd';
    _targetDays = 88;
    notifyListeners();
  }
}
