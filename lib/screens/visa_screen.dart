import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/visa_provider.dart';
import '../services/pdf_parser.dart';

class VisaScreen extends StatefulWidget {
  const VisaScreen({super.key});

  @override
  State<VisaScreen> createState() => _VisaScreenState();
}

class _VisaScreenState extends State<VisaScreen> {
  bool _loading = false;

  /// 📂 PDF 여러 개 선택 + FastAPI로 분석 + VisaProvider에 누적
  Future<void> _pickAndParsePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true, // ✅ 여러 개 선택
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _loading = true);

    // 선택된 모든 파일 순차 처리
    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;

      // FastAPI(or 임시)로 분석 요청
      final data = await PdfParser.parsePdf(path);

      final days = (data['daysWorked'] ?? 0) as int;
      final incomeVal = (data['income'] ?? 0) as int;
      final taxVal = (data['tax'] ?? 0) as int;
      final superVal = (data['super'] ?? 0) as int;

      // 삭제/식별용 고유 ID
      final id = DateTime.now().microsecondsSinceEpoch.toString();

      // Provider에 누적 추가
      context.read<VisaProvider>().updateFromPdf(
            id: id,
            fileName: file.name,
            days: days,
            incomeVal: incomeVal,
            taxVal: taxVal,
            superVal: superVal,
          );
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _onToggleVisaType(BuildContext context, String type) {
    context.read<VisaProvider>().setVisaType(type);
  }

  @override
  Widget build(BuildContext context) {
    final visa = context.watch<VisaProvider>();

    final isSecond = visa.visaType == '2nd';
    final isThird = visa.visaType == '3rd';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            // TODO: 로고 이미지 있으면 여기에 Image.asset 추가
            Text(
              "WORKROO",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📤 업로드 카드
              GestureDetector(
                onTap: _loading ? null : _pickAndParsePdf,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file_rounded,
                        size: 32,
                        color: const Color(0xFF3C5BFD),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _loading ? "Reading PDF(s)..." : "Upload Payslip",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📂 파일 리스트 카드
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: visa.payslips.isEmpty
                    ? Center(
                        child: Text(
                          "No payslips uploaded yet.",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: visa.payslips.length,
                          itemBuilder: (context, index) {
                            final p = visa.payslips[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.fileName,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<VisaProvider>()
                                          .removePayslip(p.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // 📊 Result + 2nd / 3rd 토글
              Row(
                children: [
                  Text(
                    "Result",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _toggleChip(
                    label: "2nd",
                    active: isSecond,
                    onTap: () => _onToggleVisaType(context, '2nd'),
                  ),
                  const SizedBox(width: 8),
                  _toggleChip(
                    label: "3rd",
                    active: isThird,
                    onTap: () => _onToggleVisaType(context, '3rd'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 📈 결과 카드
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FD),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _resultRow(
                      "Working Days",
                      "${visa.daysWorked} / ${visa.totalDays}",
                    ),
                    _resultRow("Income", "A\$${visa.income}"),
                    _resultRow("Total Tax", "A\$${visa.tax}"),
                    _resultRow("Net Pay", "A\$${visa.netPay}"),
                    _resultRow(
                      "Superannuation",
                      "A\$${visa.superannuation}",
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: visa.progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE0E7FF),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF3C5BFD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🤖 AI Feedback 카드
              _AIFeedbackCard(message: visa.aiFeedback),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3C5BFD) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIFeedbackCard extends StatelessWidget {
  final String message;
  const _AIFeedbackCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isDone =
        message.contains("achieved") || message.contains("completed");

    return Card(
      color: isDone ? const Color(0xFFE9FFF0) : const Color(0xFFEFF6FF),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.auto_awesome,
              color: isDone ? Colors.green : const Color(0xFF3C5BFD),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF172554),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
