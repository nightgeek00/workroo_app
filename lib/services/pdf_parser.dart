/// 안전한 PDF 파서 (테스트 및 웹 환경 대응용)
/// 실제 앱 출시 전, pdf_text 또는 pdfx로 교체 가능

class PdfParser {
  /// PDF 파일 경로를 받아서 분석한 결과를 반환
  /// 지금은 웹/테스트 환경에서도 오류 없이 통과하도록 구성됨
  static Future<Map<String, dynamic>> parsePdf(String path) async {
    // 🔹 테스트용 임시 데이터 반환
    // PDF 파싱은 추후 실제 앱(모바일/윈도우) 환경에서만 수행
    print('⚠️ PDF parsing skipped (test-safe dummy mode)');

    return {
      'daysWorked': 0, // PDF로부터 근무일 계산 (임시)
      'income': 0,     // PDF 내 Income (임시)
      'tax': 0,        // PDF 내 Tax (임시)
    };
  }
}
