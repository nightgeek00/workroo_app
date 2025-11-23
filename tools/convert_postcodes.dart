import 'dart:convert';
import 'dart:io';

/// ✅ 안전 버전: 폴더 자동 생성 + 경로 오류 방지
void main() {
  final inputPath = 'raw_postcodes.txt';
  final outputDir = Directory('assets/data');
  final outputFile = File('${outputDir.path}/visa_postcodes.json');

  // 입력 파일 존재 확인
  if (!File(inputPath).existsSync()) {
    print('❌ 오류: raw_postcodes.txt 파일을 찾을 수 없습니다.');
    print('💡 프로젝트 루트 폴더에 raw_postcodes.txt를 추가하세요.');
    exit(1);
  }

  // 출력 폴더 없으면 자동 생성
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    print('📁 "assets/data" 폴더가 없어서 새로 만들었습니다.');
  }

  // 텍스트 읽기
  final sourceText = File(inputPath).readAsStringSync();
  final regions = <String, List<List<int>>>{};
  String? currentState;

  for (final line in sourceText.split('\n')) {
    final text = line.trim();
    if (text.isEmpty) continue;

    // 주 이름 (대문자로 시작, 숫자 없음)
    if (RegExp(r'^[A-Z]').hasMatch(text) && !text.contains(',')) {
      currentState = text;
      regions[currentState] = [];
      continue;
    }

    // 우편번호 범위 또는 단일 번호
    if (currentState != null) {
      final items = text.split(',');
      for (final item in items) {
        final range = RegExp(r'(\d+)\s*to\s*(\d+)').firstMatch(item);
        final single = RegExp(r'\d+').firstMatch(item);
        if (range != null) {
          regions[currentState]!.add([
            int.parse(range.group(1)!),
            int.parse(range.group(2)!)
          ]);
        } else if (single != null) {
          final val = int.parse(single.group(0)!);
          regions[currentState]!.add([val, val]);
        }
      }
    }
  }

  outputFile.writeAsStringSync(jsonEncode(regions), mode: FileMode.write);
  print('✅ 변환 완료: ${outputFile.path}');
}
