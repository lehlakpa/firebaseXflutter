import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../widgets/fade_in_slide.dart';
import '../core/responsive.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    const themeBg = Color(0xFF070A11);
    const cardBg = Color(0xFF121721);
    const accent = Color(0xFFFFB300);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        backgroundColor: themeBg,
        surfaceTintColor: themeBg,
        elevation: 0,
      ),
      body: FadeInSlide(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseAuth.instance.currentUser != null
              ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots()
              : null,
          builder: (context, snapshot) {
            final authService = AuthService();
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              return Center(
                child: Text(
                  'Please log in to view profile.',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.redAccent),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No profile data found.',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => authService.logout(),
                      style: ElevatedButton.styleFrom(backgroundColor: accent),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!.data()!;

            return SingleChildScrollView(
              padding: EdgeInsets.all(responsive.s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accent, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: cardBg,
                        child: Text(
                          user.email?.substring(0, 1).toUpperCase() ?? "U",
                          style: GoogleFonts.montserrat(
                            fontSize: 32,
                            color: accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.s(20)),
                  Text(
                    user.email ?? "No email",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: responsive.fs(18),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.s(40)),

                  _buildProfileSection('Personal Information', [
                    _ProfileItem(
                      icon: Icons.phone,
                      label: 'Contact Number',
                      value: data['contactNumber'] ?? 'Not set',
                      accent: accent,
                    ),
                    _ProfileItem(
                      icon: Icons.map,
                      label: 'Province',
                      value: data['province'] ?? 'Not set',
                      accent: accent,
                    ),
                    _ProfileItem(
                      icon: Icons.location_on,
                      label: 'Tole/Street',
                      value: data['tole'] ?? 'Not set',
                      accent: accent,
                    ),
                  ], cardBg),

                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await authService.logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(
                      "Logout",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withAlpha(30),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    String title,
    List<_ProfileItem> items,
    Color cardBg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x0DFFFFFF)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(color: Color(0x0DFFFFFF), height: 24),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
