import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/job.dart';
import '../services/exchange_service.dart';
import '../services/time_service.dart';
import '../services/notification_service.dart';
import 'map_screen.dart';

class LayarDetailLowongan extends StatefulWidget {
  final Job job;
  const LayarDetailLowongan({super.key, required this.job});

  @override
  State<LayarDetailLowongan> createState() => _LayarDetailLowonganState();
}

class _LayarDetailLowonganState extends State<LayarDetailLowongan> {
  String selectedCurrency = 'IDR';
  Map<String, double> convertedSalary = {};
  String selectedZone = 'WIB';
  String convertedTime = 'Memuat...';
  bool isFavorite = false;
  bool loadingSalary = true;
  bool loadingTime = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    final sessionBox = Hive.box('session');
    final String? email = sessionBox.get('email');
    userId = sessionBox.get('email')?.toString().trim() ?? 'unknown_user';
    initializeDateFormatting('id_ID', null);
    _loadData();
    _checkFavorite();
  }

  Future<void> _loadData() async {
    await _loadSalary();
    await _loadTime();
  }

  Future<void> _loadSalary() async {
    setState(() => loadingSalary = true);
    final result = await ExchangeService.convertSalary(widget.job.salary);
    setState(() {
      convertedSalary = result;
      loadingSalary = false;
    });
  }

  Future<void> _loadTime() async {
    setState(() => loadingTime = true);

    final baseStart = '${DateTime.now().toString().substring(0, 11)}07:00:00';
    final baseEnd = '${DateTime.now().toString().substring(0, 11)}17:00:00';
    final start = await TimeService.getConvertedTime(baseStart, selectedZone);
    final end = await TimeService.getConvertedTime(baseEnd, selectedZone);
    setState(() {
      convertedTime =
          '${start.substring(11, 16)} - ${end.substring(11, 16)} $selectedZone';
      loadingTime = false;
    });
  }

  void _checkFavorite() {
    final box = Hive.box('favorit');
    final String key = '${userId}_${widget.job.id}';
    setState(() {
      isFavorite = box.containsKey(key);
    });
  }

  Future<void> _toggleFavorite() async {
    final box = Hive.box('favorit');
    final String key = '${userId}_${widget.job.id}';

    if (isFavorite) {
      await box.delete(key);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${widget.job.job_title} dihapus dari favorit')),
        );
      }
    } else {
      await box.put(key, widget.job.toJson());
      await NotificationService()
          .showFavoriteNotification(widget.job.job_title);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${widget.job.job_title} ditambahkan ke favorit'),
              backgroundColor: Colors.green),
        );
      }
    }

    setState(() => isFavorite = !isFavorite);
  }

  String _formatSalary() {
    final value = convertedSalary[selectedCurrency] ?? widget.job.salary;
    final formatter = NumberFormat.compactCurrency(locale: 'id', symbol: '');

    return switch (selectedCurrency) {
      'IDR' => 'Rp ${formatter.format(value)}',
      'USD' => '\$ ${value.toStringAsFixed(0)}',
      'EUR' => '€ ${value.toStringAsFixed(0)}',
      'JPY' => '¥ ${value.toStringAsFixed(0)}',
      _ => 'Rp ${formatter.format(value)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: Colors.indigo,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.job.job_title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.job.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.work,
                            size: 80, color: Colors.white)),
                  ),
                  Container(color: Colors.black38),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.attach_money,
                          color: Colors.green, size: 32),
                      title: loadingSalary
                          ? Text('Memuat gaji...', style: GoogleFonts.poppins())
                          : Text(_formatSalary(),
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                      trailing:
                          const Icon(Icons.swap_horiz, color: Colors.indigo),
                      onTap: _showCurrencyDialog,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading:
                          const Icon(Icons.access_time, color: Colors.blue),
                      title: Text('Jam Kerja',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: loadingTime
                          ? Text('Memuat waktu...',
                              style: GoogleFonts.poppins())
                          : Text(convertedTime, style: GoogleFonts.poppins()),
                      onTap: _showTimeDialog,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(widget.job.location,
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text('Bekerja dari Rumah • Penuh Waktu',
                          style: GoogleFonts.poppins(color: Colors.grey[600])),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Deskripsi Pekerjaan',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.job.description,
                      style: GoogleFonts.poppins(height: 1.6)),
                  const SizedBox(height: 16),
                  Text('Persyaratan',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...widget.job.requirements.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(r, style: GoogleFonts.poppins())),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  Text(
                    'Tingkat Pendidikan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.job.education_level,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Keterampilan yang Dibutuhkan',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.job.skills.map((skill) {
                      return Chip(
                        label: Text(
                          skill,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.indigo[700]),
                        ),
                        backgroundColor: Colors.indigo[50],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side:
                              BorderSide(color: Colors.indigo[200]!, width: 1),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Alamat Lengkap',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.job.address,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Peta Lokasi',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: MapWidget(
                      latitude: widget.job.latitude,
                      longitude: widget.job.longitude,
                      title: widget.job.company_name,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(widget.job.image)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.job.company_name,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text('Rekruter • ${widget.job.company_name}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ValueListenableBuilder<Box>(
                      valueListenable:
                          Hive.box('session').listenable(keys: ['email']),
                      builder: (context, sessionBox, _) {
                        final String userEmail =
                            sessionBox.get('email')?.toString().trim() ??
                                'guest';
                        final String lamaranKey = '${userEmail}_lamaran_list';

                        return ValueListenableBuilder<Box>(
                          valueListenable: Hive.box('profile')
                              .listenable(keys: [lamaranKey]),
                          builder: (context, profileBox, _) {
                            final List<dynamic> data =
                                profileBox.get(lamaranKey) ?? [];
                            final List<Map<String, dynamic>> lamaranList = data
                                .map((e) => Map<String, dynamic>.from(e as Map))
                                .toList();

                            final bool sudahDilamar = lamaranList
                                .any((item) => item['job_id'] == widget.job.id);

                            return ElevatedButton.icon(
                              onPressed: sudahDilamar
                                  ? () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Kamu sudah melamar "${widget.job.job_title}"'),
                                          backgroundColor: Colors.red[700],
                                        ),
                                      );
                                    }
                                  : () async {
                                      final newId =
                                          DateTime.now().millisecondsSinceEpoch;
                                      final newLamaran = {
                                        'id': newId,
                                        'job_id': widget.job.id,
                                        'title': widget.job.job_title,
                                        'company': widget.job.company_name,
                                        'location': widget.job.location ?? '',
                                        'image': widget.job.image ?? '',
                                        'date':
                                            DateFormat('d MMMM yyyy', 'id_ID')
                                                .format(DateTime.now()),
                                      };

                                      await profileBox.put(lamaranKey,
                                          [...lamaranList, newLamaran]);

                                      final countKey =
                                          '${userEmail}_lamaran_count';
                                      final current = profileBox.get(countKey,
                                          defaultValue: 0) as int;
                                      await profileBox.put(
                                          countKey, current + 1);

                                      await NotificationService()
                                          .showApplyNotification(
                                        widget.job.id,
                                        widget.job.job_title,
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: const Text(
                                            'Lamaran berhasil dikirim!',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          action: SnackBarAction(
                                            label: 'Lihat Lamaran',
                                            textColor: Colors.white,
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/lamaran');
                                            },
                                          ),
                                        ),
                                      );
                                    },
                              icon: sudahDilamar
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.white)
                                  : const Icon(Icons.send, color: Colors.white),
                              label: Text(
                                sudahDilamar
                                    ? 'SUDAH DILAMAR'
                                    : 'LAMAR SEKARANG',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sudahDilamar
                                    ? Colors.grey[600]
                                    : Colors.indigo,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 6,
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
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pilih Mata Uang',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['IDR', 'USD', 'EUR', 'JPY'].map((curr) {
            return RadioListTile<String>(
              title: Text(curr, style: GoogleFonts.poppins()),
              value: curr,
              groupValue: selectedCurrency,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedCurrency = val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pilih Zona Waktu',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['WIB', 'WITA', 'WIT', 'London'].map((zone) {
            return ListTile(
              title: Text(zone,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              trailing: selectedZone == zone
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () async {
                setState(() => selectedZone = zone);
                await _loadTime();
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
