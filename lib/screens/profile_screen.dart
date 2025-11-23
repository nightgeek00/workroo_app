import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../provider/visa_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visa = context.watch<VisaProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 프로필 카드
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFE0E7FF),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF3C5BFD),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "John Smith",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "john.smith@email.com",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.airplane_ticket_rounded,
                              color: Color(0xFF3C5BFD)),
                          const SizedBox(width: 8),
                          Text(
                            visa.progress >= 1.0
                                ? "✅ Second Visa achieved!"
                                : "Visa Progress: ${(visa.progress * 100).toStringAsFixed(0)}%",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF172554),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 설정 섹션
            Text(
              "Settings",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF172554),
              ),
            ),
            const SizedBox(height: 12),
            const _SettingsTile(
              icon: Icons.settings_outlined,
              title: "Account Settings",
            ),
            const _SettingsTile(
              icon: Icons.notifications_outlined,
              title: "Notification Preferences",
            ),
            const _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: "Help & Support",
            ),
            const SizedBox(height: 16),

            // 🔹 로그아웃 버튼
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(
                  "Sign Out",
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF3C5BFD)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF172554),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Color(0xFF94A3B8)),
        onTap: () {},
      ),
    );
  }
}
