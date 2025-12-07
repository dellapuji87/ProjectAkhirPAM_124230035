import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:lokerin/screens/developer.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _lamaranCount = 0;
  Timer? _refreshTimer;

  bool _isProfileEditing = false;
  String _profilePhotoPath = '';
  bool _hasPhoto = false;
  String? cvPath;
  bool cvUploaded = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _jobTypeController;
  late TextEditingController _skillController;
  late TextEditingController _aboutController;
  late String userId;

  final GlobalKey<FormState> _educationFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final sessionBox = Hive.box('session');
    userId = sessionBox.get('email') ?? '';
    _loadAllData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadLamaranCount();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _jobTypeController.dispose();
    _skillController.dispose();
    _aboutController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadAllData() {
    _loadProfileData();
    _loadPhotoData();
    _loadAboutData();
    _loadLamaranCount();
  }

  void _loadPhotoData() {
    final profileBox = Hive.box('profile');
    final key = '${userId}_profile_photo';
    final savedPath = profileBox.get(key) as String?;

    if (savedPath != null && savedPath.isNotEmpty) {
      if (File(savedPath).existsSync()) {
        setState(() {
          _profilePhotoPath = savedPath;
          _hasPhoto = true;
        });
      }
    }
  }

  void _loadProfileData() {
    final sessionBox = Hive.box('session');
    final profileBox = Hive.box('profile');
    _nameController = TextEditingController(text: sessionBox.get('name') ?? '');
    _phoneController = TextEditingController(
        text: profileBox.get('${userId}_phone', defaultValue: ''));
    _emailController =
        TextEditingController(text: sessionBox.get('email') ?? '');
    _jobTypeController = TextEditingController(
        text: profileBox.get('${userId}_jobtype', defaultValue: ''));
    _locationController = TextEditingController(
        text: profileBox.get('${userId}_location', defaultValue: ''));
    _skillController = TextEditingController();
  }

  void _loadAboutData() {
    final profileBox = Hive.box('profile');
    _aboutController = TextEditingController(
      text: profileBox.get('${userId}_about', defaultValue: ''),
    );
  }

  void _loadLamaranCount() {
    final profileBox = Hive.box('profile');
    setState(() {
      _lamaranCount =
          profileBox.get('${userId}_lamaran_count', defaultValue: 0);
    });
  }

  void _toggleProfileEdit() {
    setState(() {
      _isProfileEditing = true;
    });
  }

  void _saveAllChanges() {
    final sessionBox = Hive.box('session');
    final profileBox = Hive.box('profile');

    sessionBox.put('name', _nameController.text.trim());
    profileBox.put('${userId}_phone', _phoneController.text.trim());
    profileBox.put('${userId}_jobtype', _jobTypeController.text.trim());
    profileBox.put('${userId}_location', _locationController.text.trim());

    if (_hasPhoto) {
      profileBox.put('${userId}_profile_photo', _profilePhotoPath);
    }
    profileBox.put('${userId}_about', _aboutController.text.trim());

    setState(() {
      _isProfileEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil disimpan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    String? originalPath = result.files.single.path;
    if (originalPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membaca file')),
      );
      return;
    }

    final file = File(originalPath);

    if (await file.length() > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto terlalu besar! Maksimal 5MB'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final newPath = '${appDir.path}/${userId}_profile_photo.jpg';

    final savedFile = await file.copy(newPath);

    final profileBox = Hive.box('profile');
    await profileBox.put('${userId}_profile_photo', savedFile.path);

    setState(() {
      _profilePhotoPath = savedFile.path;
      _hasPhoto = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto profil berhasil diupload!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildLamaranCard(),
            const SizedBox(height: 24),
            _buildEducationCard(),
            const SizedBox(height: 16),
            _buildSkillsCard(),
            const SizedBox(height: 16),
            _buildCVCards(),
            const SizedBox(height: 16),
            _buildAboutCard(),
            const SizedBox(height: 16),
            _buildDeveloperProfileButton(),
            const SizedBox(height: 16),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box('profile').listenable(keys: ['${userId}_profile_photo']),
      builder: (context, box, _) {
        final savedPath = box.get('${userId}_profile_photo') as String?;
        final hasPhoto = savedPath != null &&
            savedPath.isNotEmpty &&
            File(savedPath).existsSync();
        _profilePhotoPath = hasPhoto ? savedPath : '';
        _hasPhoto = hasPhoto;

        return Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _toggleProfileEdit();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.indigo),
                            const SizedBox(width: 12),
                            Text(
                              'Edit Profil',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.indigo[700],
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _isProfileEditing ? _pickProfilePhoto : null,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.indigo, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 110,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade400,
                              Colors.indigo.shade600
                            ],
                          ),
                        ),
                        child: _hasPhoto
                            ? ClipOval(
                                child: Image.file(
                                  File(_profilePhotoPath),
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildEmptyPhoto(),
                                ),
                              )
                            : _buildEmptyPhoto(),
                      ),
                      if (_isProfileEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _isProfileEditing
                    ? TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nama Lengkap',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 24,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    : Text(
                        _nameController.text.isEmpty
                            ? '-'
                            : _nameController.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                const SizedBox(height: 28),
                _buildSimpleField(
                  icon: Icons.phone,
                  label: 'WHATSAPP',
                  controller: _phoneController,
                  isEditing: _isProfileEditing,
                  hintText: '08...',
                   keyboardType: TextInputType.number,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                _buildSimpleField(
                  icon: Icons.email,
                  label: 'EMAIL',
                  controller: _emailController,
                  isEditing: false,
                ),
                const SizedBox(height: 16),
                _buildSimpleField(
  icon: Icons.person,
  label: 'JENIS KELAMIN',
  controller: _jobTypeController,
  isEditing: _isProfileEditing,
  customChild: _isProfileEditing
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JENIS KELAMIN',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.indigo, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _jobTypeController.text.isEmpty
                        ? null
                        : _jobTypeController.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: ['Pria', 'Wanita']
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _jobTypeController.text = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        )
      : null,
),

                if (_isProfileEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _saveAllChanges,
                        icon: const Icon(Icons.save,
                            color: Colors.white, size: 24),
                        label: Text(
                          'SIMPAN',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.green.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? customChild,
  }) {
     if (customChild != null) return customChild;

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: Colors.indigo, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: isEditing
                  ? TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                      style: GoogleFonts.poppins(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : Text(
                      controller.text.isEmpty ? '-' : controller.text,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.black87),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyPhoto() {
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 44, color: Colors.white70),
          const SizedBox(height: 8),
          Text(
            'Foto Profil',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLamaranCard() {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('session').listenable(keys: ['email']),
      builder: (context, sessionBox, _) {
        final String userEmail =
            sessionBox.get('email')?.toString().trim() ?? 'guest';
        final String countKey = '${userEmail}_lamaran_count';

        return ValueListenableBuilder<Box>(
          valueListenable: Hive.box('profile').listenable(keys: [countKey]),
          builder: (context, profileBox, _) {
            final int count = profileBox.get(countKey, defaultValue: 0);

            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/lamaran'),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.indigo.shade50, Colors.white]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.shopping_bag,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$count',
                                style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo)),
                            Text('Lamaran Kerja',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo[700])),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.indigo[400]),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEducationCard() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('profile').listenable(
          keys: ['${userId}_education', '${userId}_editing_education']),
      builder: (context, profileBox, _) {
        final education = profileBox.get('${userId}_education');
        final isEditingEducation = profileBox.get(
          '${userId}_editing_education',
          defaultValue: false,
        );
        final isComplete = education != null &&
            education['level'] != null &&
            education['school'] != null;

        return Card(
          elevation: 4,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _educationFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo.shade600,
                                  Colors.indigo.shade700,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.school,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PENDIDIKAN',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Latar belakang',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isComplete ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isComplete ? 'LENGKAP' : 'BELUM',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!isEditingEducation) ...[
                    if (isComplete)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.indigo.shade200!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.school, color: Colors.indigo, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${education!['level']} - ${education['school']} - ${education['major']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 32,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tambahkan pendidikan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  if (isEditingEducation) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: education?['level'],
                      validator: (value) => value == null
                          ? 'Tingkat pendidikan wajib diisi'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Tingkat Pendidikan',
                        labelStyle:
                            GoogleFonts.poppins(color: Colors.indigo[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                      items: ['S1', 'S2', 'D3', 'D4', 'SMA', 'SMK']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        final newEducation = Map<String, dynamic>.from(
                          education ?? {},
                        );
                        newEducation['level'] = value;
                        profileBox.put('${userId}_education', newEducation);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: education?['school'],
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Nama sekolah/universitas wajib diisi'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Nama Sekolah/Universitas',
                        labelStyle:
                            GoogleFonts.poppins(color: Colors.indigo[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        final newEducation = Map<String, dynamic>.from(
                          education ?? {},
                        );
                        newEducation['school'] = value;
                        profileBox.put('${userId}_education', newEducation);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: education?['major'],
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Jurusan / Program Studi wajib diisi'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Jurusan / Program Studi',
                        labelStyle:
                            GoogleFonts.poppins(color: Colors.indigo[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        final newEducation =
                            Map<String, dynamic>.from(education ?? {});
                        newEducation['major'] = value.trim();
                        profileBox.put('${userId}_education', newEducation);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: Icon(isEditingEducation ? Icons.save : Icons.edit),
                      label: Text(
                        isEditingEducation ? 'SIMPAN' : 'EDIT PENDIDIKAN',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isEditingEducation ? Colors.green : Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (isEditingEducation) {
                          if (_educationFormKey.currentState!.validate()) {
                            profileBox.put(
                                '${userId}_editing_education', false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pendidikan disimpan!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          profileBox.put('${userId}_editing_education', true);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillsCard() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('profile')
          .listenable(keys: ['${userId}_skills', '${userId}_editing_skills']),
      builder: (context, profileBox, _) {
        final skills = List<String>.from(
          profileBox.get('${userId}_skills', defaultValue: <String>[]),
        );
        final isEditingSkills = profileBox.get(
          '${userId}_editing_skills',
          defaultValue: false,
        );

        return Card(
          elevation: 4,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.green.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(Icons.star, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SKILLS',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Keahlian kamu',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: skills.isNotEmpty ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skills.isNotEmpty ? 'LENGKAP' : 'BELUM',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!isEditingSkills) ...[
                  if (skills.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: skills.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(
                              skills[index],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.indigo.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.indigo.shade200!),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_outline,
                                size: 32, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Tambahkan skills',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                if (isEditingSkills) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      labelText: 'Ketik skill baru',
                      labelStyle:
                          GoogleFonts.poppins(color: Colors.indigo[700]),
                      hintText: 'Contoh: Flutter, Dart, UI/UX',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.indigo, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          final text = _skillController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              skills.add(text);
                              profileBox.put('${userId}_skills', skills);
                            });
                            _skillController.clear();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      final text = value.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          skills.add(text);
                          profileBox.put('${userId}_skills', skills);
                        });
                        _skillController.clear();
                      }
                    },
                  ),
                  if (skills.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: skills.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(
                              skills[index],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.indigo.shade50,
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                skills.removeAt(index);
                                profileBox.put('${userId}_skills', skills);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: Icon(isEditingSkills ? Icons.save : Icons.edit),
                    label: Text(
                      isEditingSkills ? 'SIMPAN' : 'EDIT SKILLS',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isEditingSkills ? Colors.green : Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (isEditingSkills) {
                        profileBox.put('${userId}_editing_skills', false);
                        _skillController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Skills disimpan!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        profileBox.put('${userId}_editing_skills', true);
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCVCards() {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('profile').listenable(
        keys: ['${userId}_cv_path'],
      ),
      builder: (context, box, _) {
        cvPath = box.get('${userId}_cv_path');
        final bool isComplete = cvPath != null && cvPath!.isNotEmpty;

        return Card(
          elevation: 4,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade600,
                                Colors.red.shade700
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.picture_as_pdf,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CV',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Upload CV',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isComplete ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isComplete ? 'LENGKAP' : 'BELUM',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isComplete ? Colors.green.shade50 : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isComplete ? Colors.green : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: isComplete
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 36, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CV Siap Digunakan",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cvPath!.split('/').last,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon:
                                        const Icon(Icons.visibility, size: 20),
                                    label: const Text("Lihat PDF"),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.indigo),
                                    onPressed: () => _openCV(cvPath!),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    label: const Text("Hapus CV",
                                        style: TextStyle(color: Colors.red)),
                                    style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.red)),
                                    onPressed: _deleteCV,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('Upload PDF',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700])),
                            const SizedBox(height: 4),
                            Text('Maksimal 5MB',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.grey[500])),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(isComplete ? 'GANTI CV' : 'UPLOAD CV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _pickAndSavePDF,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndSavePDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final pickedFile = result.files.single;
    if (pickedFile.size > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('File terlalu besar! Maksimal 5MB'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final cvDir = Directory('${appDir.path}/cv');
    if (!await cvDir.exists()) await cvDir.create(recursive: true);

    final String formattedDate =
        DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());

    final fileName = 'CV_${userId}_$formattedDate.pdf';
    final savedFile =
        await File(pickedFile.path!).copy('${cvDir.path}/$fileName');

    final box = Hive.box('profile');
    await box.put('${userId}_cv_path', savedFile.path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('CV berhasil diupload!'),
          backgroundColor: Colors.green),
    );
  }

  Future<void> _openCV(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await OpenFilex.open(path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('File CV tidak ditemukan, silakan upload ulang'),
            backgroundColor: Colors.red),
      );
      await _deleteCV();
    }
  }

  Future<void> _deleteCV() async {
    final box = Hive.box('profile');
    final String? currentPath = box.get('${userId}_cv_path');

    if (currentPath != null) {
      final file = File(currentPath);
      if (await file.exists()) await file.delete();
    }

    await box.delete('${userId}_cv_path');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('CV berhasil dihapus'), backgroundColor: Colors.green),
    );
  }

  Widget _buildAboutCard() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('profile')
          .listenable(keys: ['${userId}_about', '${userId}_editing_about']),
      builder: (context, profileBox, _) {
        _aboutController.text =
            profileBox.get('${userId}_about', defaultValue: '');
        final about = _aboutController.text;
        final isEditingAbout =
            profileBox.get('${userId}_editing_about', defaultValue: false);
        final isComplete = about.isNotEmpty;

        return Card(
          elevation: 4,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade700
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(Icons.info, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TENTANG SAYA',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Ceritakan diri Anda',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isComplete ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isComplete ? 'LENGKAP' : 'BELUM',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!isEditingAbout)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 100),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isComplete ? Colors.blue.shade50 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isComplete
                            ? Colors.indigo.shade600!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: isComplete
                        ? SingleChildScrollView(
                            child: Text(
                              about,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_note,
                                  size: 32, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'Tambahkan deskripsi tentang diri Anda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                if (isEditingAbout) ...[
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 6,
                    maxLength: 2600,
                    controller: _aboutController,
                    onChanged: (value) {
                      profileBox.put('${userId}_about', value);
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Ceritakan tentang diri Anda, pengalaman kerja, dan keahlian...',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[500], fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.indigo, width: 2),
                      ),
                      counterText: '', // Hilangkan counter
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: Icon(isEditingAbout ? Icons.save : Icons.edit),
                    label: Text(
                      isEditingAbout ? 'SIMPAN' : 'EDIT DESKRIPSI',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isEditingAbout ? Colors.green : Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (isEditingAbout) {
                        profileBox.put('${userId}_editing_about', false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              about.isNotEmpty
                                  ? 'Deskripsi disimpan!'
                                  : 'ℹ️ Deskripsi kosong, tapi mode edit ditutup',
                            ),
                            backgroundColor:
                                about.isNotEmpty ? Colors.green : Colors.red,
                          ),
                        );
                      } else {
                        profileBox.put('${userId}_editing_about', true);
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeveloperProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DeveloperProfileScreen()),
          );
        },
        icon: const Icon(Icons.code, color: Colors.indigo),
        label: Text(
          'Profil Pengembang',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.indigo,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.indigo, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Keluar',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: () {
          Hive.box('session').clear();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
      ),
    );
  }
}
