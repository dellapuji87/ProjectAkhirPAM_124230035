// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FOTO PROFIL
            CircleAvatar(
              radius: 70,
              backgroundImage:
                  const AssetImage('assets/images/profildella.jpg'),
              onBackgroundImageError: (_, __) =>
                  const Icon(Icons.person, size: 70),
            ),
            const SizedBox(height: 16),

            // NAMA & EMAIL DARI HIVE
            ValueListenableBuilder(
              valueListenable: Hive.box('session').listenable(),
              builder: (context, box, _) {
                final name = box.get('name', defaultValue: 'User');
                final email =
                    box.get('email', defaultValue: 'user@lokerin.com');
                return Column(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL UTAMA
                    Text(
                      'Identitas Diri',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 12),

                    Text('Nama: Della Puji Astuti',
                        style: GoogleFonts.poppins(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('NIM: 124230035',
                        style: GoogleFonts.poppins(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Kelas: SI-B',
                        style: GoogleFonts.poppins(fontSize: 14)),

                    const SizedBox(height: 16),

                    // KESAN PAM
                    Text(
                      'Kesan PAM',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'WOW! 감사합니다, Mobilee! 진짜 진짜 대박-! '
                      'Asiknya dapet banget, pusingnya apalagi. '
                      'Momen error misterius yang muncul di tengah malam.. Sangat berkesan! '
                      'Mobile 너무 좋아요! ^^',
                      style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL LOGOUT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Keluar',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Hive.box('session').clear();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
