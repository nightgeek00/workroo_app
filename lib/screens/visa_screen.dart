import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../provider/visa_provider.dart';
import '../services/pdf_parser.dart';
import 'package:google_fonts/google_fonts.dart';

class VisaScreen extends StatefulWidget {
  const VisaScreen({super.key});

  @override
  State<VisaScreen> createState() => _VisaScreenState();
}

class _VisaScreenState extends State<VisaScreen> {
  bool _loading = false;

  Future<void> _pickAndParsePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    setState(() => _loading = true);
    final data = await PdfParser.parsePdf(path);

    if (!mounted) return;

    context.read<VisaProvider>().updateFromPdf(
          days: data['daysWorked'],
          incomeVal: data['income'],
          taxVal: data['tax'],
        );

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final visa = context.watch<VisaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Visa Status"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F8FD),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _pickAndParsePdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C5BFD),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(
                _loading ? "Reading PDF..." : "Upload Payslip PDF",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Card
            _VisaInfoCard(
              daysWorked: visa.daysWorked,
              totalDays: visa.totalDays,
              income: visa.income,
              tax: visa.tax,
              progress: visa.progress,
            ),

            const SizedBox(height: 16),

            // AI Feedback
            _AIFeedbackCard(message: visa.aiFeedback),
          ],
        ),
      ),
    );
  }
}

class _VisaInfoCard extends StatelessWidget {
  final int daysWorked;
  final int totalDays;
  final int income;
  final int tax;
  final double progress;

  const _VisaInfoCard({
    required this.daysWorked,
    required this.totalDays,
    required this.income,
    required this.tax,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Visa Progress",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF172554),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$daysWorked / $totalDays days",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF172554),
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE0E7FF),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF3C5BFD)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(label: "Income", value: "A\$${income}"),
                _SummaryItem(label: "Tax", value: "A\$${tax}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF172554),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[700] ?? Colors.grey,
          ),
        ),
      ],
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
