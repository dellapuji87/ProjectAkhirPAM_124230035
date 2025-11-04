import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/job.dart';
import 'detail_lowongan.dart';
import 'package:intl/intl.dart';

class LayarFavorit extends StatelessWidget {
  const LayarFavorit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('favorit').listenable(),
        builder: (context, box, _) {
          // AMBIL KEYS YANG VALID
          final keys = box.keys.whereType<String>().toList();

          if (keys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada lowongan favorit',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan hati untuk menyimpan lowongan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // PARSE JOB DENGAN AMAN
          final List<Job> jobs = [];
          for (final key in keys) {
            final data = box.get(key);
            if (data == null) continue;

            try {
              final map = Map<String, dynamic>.from(data as Map);
              final job = Job.fromJson(map);
              jobs.add(job);
            } catch (e) {
              print('Error parsing job $key: $e');
            }
          }

          if (jobs.isEmpty) {
            return Center(
              child: Text(
                'Data favorit rusak. Silakan hapus & tambah ulang.',
                style: GoogleFonts.poppins(color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: jobs.length,
            itemBuilder: (context, i) {
              final job = jobs[i];
              return Card(
                color: Colors.white,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(job.image),
                    onBackgroundImageError: (_, __) => null,
                    child: job.image.isEmpty
                        ? const Icon(Icons.work, size: 28, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    job.job_title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        job.company_name,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.location,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat.compact(locale: 'id').format(job.salary)}',
                        style: GoogleFonts.poppins(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
                    onPressed: () async {
    final String key = job.id.toString();
    await box.delete(key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${job.job_title} dihapus dari favorit'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LayarDetailLowongan(job: job),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}