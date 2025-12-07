import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/hash.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isLoading = false;

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Semua field wajib diisi!', error: true);
      return;
    }
    if (!email.contains('@')) {
      _showSnackBar('Email tidak valid!', error: true);
      return;
    }
    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter!', error: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar('Password tidak sama!', error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userBox = Hive.box('users');

      if (userBox.containsKey(email)) {
        _showSnackBar('Email sudah terdaftar!', error: true);
        return;
      }

      await userBox.put(email, {
        'name': name,
        'password': AuthUtils.hashPassword(password),
      });

      _showSnackBar('Registrasi berhasil! Silakan masuk!', error: false);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan. Coba lagi.', error: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            const Icon(Icons.work, size: 80, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              'LokerIn',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            Text(
              'Daftar untuk menemukan lowongan kerja terbaik di Yogyakarta!',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: const Icon(Icons.person),
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                labelStyle: GoogleFonts.poppins(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              obscureText: _isObscure2,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                prefixIcon: const Icon(Icons.lock_outline),
                labelStyle: GoogleFonts.poppins(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure2 ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscure2 = !_isObscure2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Daftar',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sudah punya akun? ',
                  style: GoogleFonts.poppins(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'Masuk',
                    style: GoogleFonts.poppins(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
