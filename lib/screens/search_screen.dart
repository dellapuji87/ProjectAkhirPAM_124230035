import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/job.dart';
import 'detail_lowongan.dart';

class LayarPencarian extends StatefulWidget {
  const LayarPencarian({super.key});
  @override
  State<LayarPencarian> createState() => _LayarPencarianState();
}

class _LayarPencarianState extends State<LayarPencarian> {
  List<Job> semua = [];
  List<Job> hasil = [];
  final _pencarian = TextEditingController();
  bool memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => memuat = true);
    semua = await ApiLayanan.ambilSemua();
    hasil = semua;
    setState(() => memuat = false);
  }

  void _filter(String kata) {
    setState(() {
      hasil = semua
          .where((j) =>
              j.job_title.toLowerCase().contains(kata.toLowerCase()) ||
              j.company_name.toLowerCase().contains(kata.toLowerCase()) ||
              j.location.toLowerCase().contains(kata.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _pencarian,
              decoration: InputDecoration(
                labelText: 'Cari lowongan, perusahaan, atau lokasi...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: memuat
                ? const Center(child: CircularProgressIndicator())
                : hasil.isEmpty
                    ? const Center(child: Text('Tidak ada hasil'))
                    : ListView.builder(
                        itemCount: hasil.length,
                        itemBuilder: (context, i) {
                          final job = hasil[i];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(job.image),
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Icons.work),
                              ),
                              title: Text(job.job_title),
                              subtitle:
                                  Text('${job.company_name} • ${job.location}'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        LayarDetailLowongan(job: job)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
