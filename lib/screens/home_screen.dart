// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../model/job.dart';
import 'detail_lowongan.dart';
import '../services/notification_service.dart'; // PASTIKAN ADA

class LayarBeranda extends StatefulWidget {
  const LayarBeranda({super.key});
  @override
  State<LayarBeranda> createState() => _LayarBerandaState();
}

class _LayarBerandaState extends State<LayarBeranda> {
  List<Job> daftar = [];
  List<Job> hasilCari = [];
  bool memuat = true;
  final TextEditingController _cariController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => memuat = true);
    daftar = await ApiLayanan.ambilSemua();
    hasilCari = daftar;
    setState(() => memuat = false);
  }

  void _cari(String query) {
    setState(() {
      hasilCari = daftar
          .where((job) =>
              job.job_title.toLowerCase().contains(query.toLowerCase()) ||
              job.company_name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nama = Hive.box('session').get('name', defaultValue: 'User');

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $nama!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temukan pekerjaan impianmu di Yogyakarta!',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cariController,
                    onChanged: _cari,
                    decoration: InputDecoration(
                      hintText: 'Cari lowongan...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2.5),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
            ),

            // LIST LOWONGAN
            Expanded(
              child: memuat
                  ? const Center(child: CircularProgressIndicator())
                  : ValueListenableBuilder(
                      valueListenable: Hive.box('favorit').listenable(),
                      builder: (context, box, _) {
                        if (hasilCari.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada lowongan ditemukan',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: hasilCari.length,
                          itemBuilder: (context, i) {
                            final job = hasilCari[i];
                            final String key = job.id.toString(); // KEY STRING
                            final bool favorit =
                                box.containsKey(key); // CEK DARI HIVE

                            return Card(
                              color: Colors.white,
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(job.image),
                                  onBackgroundImageError: (_, __) => null,
                                  child: job.image.isEmpty
                                      ? const Icon(Icons.work,
                                          size: 28, color: Colors.white)
                                      : null,
                                ),
                                title: Text(
                                  job.job_title,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(job.company_name,
                                        style: GoogleFonts.poppins()),
                                    Text(job.location,
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey[600])),
                                    Text(
                                      'Rp ${NumberFormat.compact(locale: 'id').format(job.salary)}',
                                      style: GoogleFonts.poppins(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    favorit
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: favorit ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    // GUNAKAN KEY YANG SAMA
                                    if (favorit) {
                                      await box.delete(key);
                                    } else {
                                      await box.put(key, job.toJson());
                                      await NotificationService()
                                          .showFavoriteNotification(
                                              job.job_title);
                                    }

                                    // ValueListenableBuilder akan rebuild otomatis
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            LayarDetailLowongan(job: job)),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }
}
