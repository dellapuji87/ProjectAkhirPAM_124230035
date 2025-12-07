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
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('favorit').listenable(),
        builder: (context, box, _) {

          final sessionBox = Hive.box('session');
          final String currentUserId =
              sessionBox.get('email')?.toString().trim() ?? 'unknown_user';

          final userKeys = box.keys.where((key) {
            return key is String &&
                key.toString().startsWith('$currentUserId\_');
          }).toList();

          if (userKeys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada lowongan favorit',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan hati untuk menyimpan lowongan',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final List<Job> jobs = [];
          for (final key in userKeys) {
            final data = box.get(key);
            if (data == null) continue;
            try {
              final map = Map<String, dynamic>.from(data as Map);
              jobs.add(Job.fromJson(map));
            } catch (e) {
              print('Error parsing favorite: $e');
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: jobs.length,
            itemBuilder: (context, i) {
              final job = jobs[i];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(job.image),
                    onBackgroundImageError: (_, __) => null,
                  ),
                  title: Text(job.job_title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.company_name),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(job.location,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: Colors.grey[600]))),
                        ],
                      ),
                      Text(
                        'Rp ${NumberFormat.compact(locale: 'id').format(job.salary)}',
                        style: GoogleFonts.poppins(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      final String key = '$currentUserId\_${job.id}';
                      await box.delete(key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${job.job_title} dihapus dari favorit'),
                            backgroundColor: Colors.red),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LayarDetailLowongan(job: job)),
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
