import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LamaranScreen extends StatefulWidget {
  const LamaranScreen({super.key});

  @override
  State<LamaranScreen> createState() => _LamaranScreenState();
}

class _LamaranScreenState extends State<LamaranScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Riwayat Lamaran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: Hive.box('session').listenable(keys: ['email']),
        builder: (context, sessionBox, _) {
          final String userEmail =
              sessionBox.get('email')?.toString().trim() ?? 'guest';
          final String lamaranKey = '${userEmail}_lamaran_list';

          return ValueListenableBuilder<Box>(
            valueListenable: Hive.box('profile').listenable(keys: [lamaranKey]),
            builder: (context, profileBox, _) {
              final List<dynamic> data = profileBox.get(lamaranKey) ?? [];
              final List<Map<String, dynamic>> lamaranList =
                  data.map((e) => Map<String, dynamic>.from(e as Map)).toList();

              lamaranList
                  .sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

              if (lamaranList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 24),
                      Text('Belum ada lamaran',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Text('Mulai lamar pekerjaan favoritmu!',
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lamaranList.length,
                itemBuilder: (context, index) =>
                    _buildLamaranCard(lamaranList[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLamaranCard(Map<String, dynamic> lamaran) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send, size: 16, color: Colors.indigo),
                      const SizedBox(width: 6),
                      Text(
                        'Terkirim',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      lamaran['date']?.toString() ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'cancel') {
                          _cancelLamaran(lamaran['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              const Icon(Icons.cancel_outlined,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 12),
                              Text('Batalkan Lamaran',
                                  style:
                                      GoogleFonts.poppins(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.indigo.withOpacity(0.1),
                  ),
                  child: lamaran['image'] != null &&
                          lamaran['image'].toString().isNotEmpty &&
                          lamaran['image'].toString().startsWith('http')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            lamaran['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.business_center,
                                color: Colors.indigo),
                          ),
                        )
                      : const Icon(Icons.business_center,
                          color: Colors.indigo, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lamaran['title'] ?? 'Lowongan Tidak Diketahui',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lamaran['company'] ?? '-',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lamaran['location'] ?? 'Lokasi tidak tersedia',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelLamaran(dynamic lamaranId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.red),
            const SizedBox(width: 12),
            Text('Batalkan Lamaran?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Lamaran ini akan dihapus permanen.',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final sessionBox = Hive.box('session');
    final profileBox = Hive.box('profile');

    final String userEmail =
        sessionBox.get('email')?.toString().trim() ?? 'guest';
    final String lamaranKey = '${userEmail}_lamaran_list';
    final String countKey = '${userEmail}_lamaran_count';

    final List<dynamic> currentList =
        List.from(profileBox.get(lamaranKey, defaultValue: []));
    currentList.removeWhere((item) => item['id'] == lamaranId);
    await profileBox.put(lamaranKey, currentList);

    final int currentCount = profileBox.get(countKey, defaultValue: 0) as int;
    if (currentCount > 0) {
      await profileBox.put(countKey, currentCount - 1);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lamaran berhasil dibatalkan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
