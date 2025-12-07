import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Profil Pengembang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.indigo, const Color.fromARGB(255, 253, 146, 232)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profildella.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_rounded, color: Colors.indigo[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Della Puji Astuti',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.badge_rounded, color: Colors.indigo[600], size: 26),
                const SizedBox(width: 10),
                Text(
                  '124230035',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Pemrograman Aplikasi Mobile SI-B',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.indigo[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.favorite_border_rounded,
                              color: Colors.pink[400], size: 30),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Kesan Pesan',
                          style: GoogleFonts.poppins(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo[50]!, Colors.purple[50]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'WOW! 감사합니다, Mobilee! 진짜 진짜 대박-!\n\n'
                        'Asiknya dapet banget, pusingnya apalagi ya T_T\n'
                        'Momen error misterius tengah malam = unforgettable experience banget sih ♡\n\n'
                        'Tapi serius, Mobile 너무 좋아요! ^^',
                        style: GoogleFonts.poppins(
                          fontSize: 15.5,
                          height: 1.7,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
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