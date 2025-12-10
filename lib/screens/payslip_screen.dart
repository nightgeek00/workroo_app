import 'package:flutter/material.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 상단 헤더
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            // 로고
            Image.asset("assets/images/workroo_logo.png", height: 32),
            const SizedBox(width: 8),
            const Text(
              "WORKROO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      /// 전체 스크롤
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 12),

            /// 업로드 박스
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload, size: 32, color: Colors.blue.shade600),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Upload Payslip",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 파일 리스트 카드
            Container(
              height: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  children: [
                    _fileRow("Payslip example 1 week.pdf"),
                    _fileRow("Payslip example 2 week.pdf"),
                    _fileRow("Payslip example 3 week.pdf"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Result 제목 + 버튼
            Row(
              children: [
                const Text(
                  "Result",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                
                _toggleButton("2nd", active: true),
                const SizedBox(width: 8),
                _toggleButton("3rd", active: false),
              ],
            ),

            const SizedBox(height: 16),

            /// 결과 값
            _resultRow("Working Days", "18 / 88"),
            _resultRow("Income", "A\$3,000"),
            _resultRow("Total Tax", "A\$600"),
            _resultRow("Net Pay", "A\$2,400"),
            _resultRow("Superannuation", "A\$342"),

            const SizedBox(height: 40),
          ],
        ),
      ),

      /// 하단 네비
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Visa 선택됨
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: "Visa"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Postcode"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// 파일 Row
  Widget _fileRow(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 15)),
          ),
          const Icon(Icons.close, size: 18),
        ],
      ),
    );
  }

  /// 토글 버튼
  Widget _toggleButton(String text, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.blue.shade600 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 결과 Row
  Widget _resultRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
