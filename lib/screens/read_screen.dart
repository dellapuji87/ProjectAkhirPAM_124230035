import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LayarBaca extends StatelessWidget {
  const LayarBaca({super.key});


  final List<Map<String, String>> tips = const [
    {
      'rank': '#1',
      'title': 'Cara Menulis CV yang Menarik Perhatian HRD',
      'date': '24 September 2022',
      'reads': '8.844 kali dibaca',
      'image': 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'type': 'tip',
      'content': '''
Tips: Buat CV yang standout dengan struktur sederhana dan kata kunci relevan.

Langkah-langkah:
1. Header: Nama, kontak, LinkedIn
2. Ringkasan: 3-4 kalimat profil profesional
3. Pengalaman: Mulai dari yang terbaru, gunakan bullet points
4. Pendidikan: IPK, universitas, tahun lulus
5. Skills: Sesuaikan dengan JD lowongan

Hindari: Foto, warna berlebih, font aneh. Panjang CV: 1-2 halaman.

''',
    },
    {
      'rank': '#2',
      'title': '5 Kesalahan Umum Saat Interview Online',
      'date': '27 Desember 2022',
      'reads': '7.204 kali dibaca',
      'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'type': 'tip',
      'content': '''
Tips: Hindari kesalahan fatal di interview virtual.

Kesalahan umum:
1. Background berantakan (pakai virtual background)
2. Suara bergema (cek mikrofon & headset)
3. Terlambat join (tes link 15 menit sebelumnya)
4. Baju santai (tetap formal dari atas)
5. Tidak eye contact (lihat kamera, bukan layar)

Tips sukses: Latih jawaban STAR (Situation, Task, Action, Result). Siapkan pertanyaan balik.
''',
    },
    {
      'rank': '#3',
      'title': 'Cara Negosiasi Gaji yang Efektif',
      'date': '05 Desember 2021',
      'reads': '6.089 kali dibaca',
      'image': 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'type': 'tip',
      'content': '''
Negosiasi gaji dengan percaya diri tapi sopan.

Strategi:
1. Riset: Cek Glassdoor untuk range gaji di Jogja
2. Nilai diri: Hitung kontribusi & skill unik
3. Mulai tinggi: Usulkan 10-20% di atas tawaran
4. Fokus value: "Dengan pengalaman saya, saya bisa bawa Rp X juta tambahan revenue"
5. Siapkan alternatif: Bonus, WFH, training

Contoh: "Saya menghargai tawaran Rp 5 juta, tapi berdasarkan riset, untuk skill ini di Jogja rata-rata Rp 6 juta. Apakah bisa diskusi?"
''',
    },
    {
      'rank': '#4',
      'title': 'Building Personal Branding di LinkedIn',
      'date': '8 Januari 2023',
      'reads': '6.000 kali dibaca',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'type': 'tip',
      'content': '''
Bangun brand profesional di LinkedIn untuk karir lebih cepat.

Langkah:
1. Profil lengkap: Foto profesional, headline menarik
2. Summary: Cerita karir + skill + passion
3. Experience: Quantify achievement (e.g., "Tingkatkan sales 30%")
4. Post konten: Share artikel, insight karir
5. Network: Connect HR & alumni

Hasil: 70% lowongan datang dari LinkedIn. Update profil mingguan!
''',
    },
    {
      'rank': '#5',
      'title': 'Cara Mengatasi Burnout di Tempat Kerja',
      'date': '23 Mei 2022',
      'reads': '5.976 kali dibaca',
      'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'type': 'tip',
      'content': '''
Tips: Atasi kelelahan kerja dengan strategi sederhana.

Gejala burnout: Stres konstan, kurang motivasi, mudah marah.

Solusi:
1. Set boundary: Jam kerja ketat, no email malam
2. Istirahat: Micro-break 5 menit setiap jam
3. Olahraga: 30 menit jalan kaki harian
4. Hobi: 1 jam/hari untuk passion
5. Bicara: Konsultasi HR atau teman

Statistik: 77% pekerja muda alami burnout. Prioritaskan self-care!
''',
    },
    {
      'rank': '#6',
      'title': 'Mempersiapkan Portofolio Desain Grafis',
      'date': '21 Desember 2021',
      'reads': '5.897 kali dibaca',
      'image': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'type': 'tip',
      'content': '''
Tips: Portofolio adalah CV visual untuk desainer.

Elemen kunci:
1. Kualitas > Kuantitas: 8-12 proyek terbaik
2. Struktur: Logo, UI/UX, Print, Web
3. Proses: Sketch → Final → Tool digunakan
4. Case study: Masalah, solusi, hasil
5. Platform: Behance, Dribbble, PDF

Tips: Update setiap 3 bulan. Sertakan feedback klien.
''',
    },
    {
      'rank': '#7',
      'title': 'Strategi Networking untuk Fresh Graduate',
      'date': '25 November 2021',
      'reads': '5.893 kali dibaca',
      'image': 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'type': 'tip',
      'content': '''
Networking = 85% sukses karir.

Cara efektif:
1. LinkedIn: Connect 5 orang/hari (alumni, HR)
2. Event: Job fair, webinar karir di Jogja
3. Coffee chat: Ajak senior ngopi virtual
4. Grup WA/Telegram: Komunitas IT Jogja
5. Follow up: Email terima kasih + value tambah

Mantra: "Give first, ask later." Bagikan tips, bukan minta lowongan.
''',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          'Tips Karir Terpopuler',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white
            ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih tips favoritmu untuk karir lebih baik!',
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),


              ...tips.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailBacaScreen(
                            title: item['title']!,
                            date: item['date']!,
                            reads: item['reads']!,
                            imageUrl: item['image']!,
                            content: item['content']!,
                            type: item['type']!,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      elevation: 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GAMBAR
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              item['image']!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 160,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // RANK
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item['rank']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item['title']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // SUBTITLE (DATE & READS)
                                Row(
                                  children: [
                                    Text(
                                      item['date']!,
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      item['reads']!,
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}



class DetailBacaScreen extends StatelessWidget {
  final String title;
  final String date;
  final String reads;
  final String imageUrl;
  final String content;
  final String type;

  const DetailBacaScreen({
    super.key,
    required this.title,
    required this.date,
    required this.reads,
    required this.imageUrl,
    required this.content,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          'Detail Tips',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR BESAR
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 60),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RANK & DATE
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'POPULER',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        reads,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // JUDUL
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ISI LENGKAP
                  Text(
                    content,
                    style: GoogleFonts.poppins(fontSize: 15, height: 1.7),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}