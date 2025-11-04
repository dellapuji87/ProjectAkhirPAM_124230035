import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/job.dart';
import '../services/exchange_service.dart';
import '../services/time_service.dart';
import '../services/notification_service.dart';
import 'map_screen.dart'; // Asumsikan MapWidget ada di sini

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

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkFavorite();
  }

  Future<void> _loadData() async {
    await _loadSalary();
    await _loadTime();
  }

  Future<void> _loadSalary() async {
    setState(() => loadingSalary = true);
    // Asumsi widget.job.salary bertipe double (sesuai model Job)
    final result = await ExchangeService.convertSalary(widget.job.salary);
    setState(() {
      convertedSalary = result;
      loadingSalary = false;
    });
  }

  Future<void> _loadTime() async {
    setState(() => loadingTime = true);
    // Logika konversi waktu tetap sama
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
    // Menggunakan ID sebagai string untuk Hive key
    setState(() => isFavorite = box.containsKey(widget.job.id.toString()));
  }

  Future<void> _toggleFavorite() async {
    final box = Hive.box('favorit');
    final String key = widget.job.id.toString(); // Key Hive menggunakan String

    if (isFavorite) {
      await box.delete(key);
    } else {
      await box.put(key, widget.job.toJson());

      // Notif langsung (menggunakan ID INT)
      await NotificationService()
          .showFavoriteNotification(widget.job.job_title);
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
                  // GAJI
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

                  // JAM KERJA
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

                  // LOKASI
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

                  // DESKRIPSI & PERSYARATAN
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

                  // MINIMAL EDUCATION
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

                  // TAMBAHAN: SKILLS
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

                  // MAP
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

                  // PERUSAHAAN
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

                  // TOMBOL
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: Text('CHAT UNTUK MELAMAR',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        await NotificationService().showApplyNotification(
                          widget.job.id,
                          widget.job.job_title,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Bisa lamar tanpa CV, lamar sekarang!',
                          style: GoogleFonts.poppins(color: Colors.indigo)),
                    ),
                  ),
                  const SizedBox(height: 24),
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
