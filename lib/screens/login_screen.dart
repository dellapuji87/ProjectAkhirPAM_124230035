// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/hash.dart'; // bcrypt
import 'register_screen.dart';
import '../main.dart'; // NavigasiUtama

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // VALIDASI DASAR
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan password wajib diisi!', error: true);
      return;
    }
    if (!email.contains('@')) {
      _showSnackBar('Email tidak valid!', error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userBox = Hive.box('users');
      final sessionBox = Hive.box('session');

      if (!userBox.containsKey(email)) {
        _showSnackBar('Email tidak terdaftar!', error: true);
        return;
      }

      final userData = userBox.get(email) as Map<dynamic, dynamic>;
      final savedHash = userData['password'] as String;

      // VERIFIKASI bcrypt
      if (!AuthUtils.verifyPassword(password, savedHash)) {
        _showSnackBar('Password salah!', error: true);
        return;
      }

      // SIMPAN SESSION LENGKAP
      await sessionBox.put('email', email);
      await sessionBox.put('name', userData['name']);
      await sessionBox.put('loggedIn', true);

      _showSnackBar('Login berhasil!');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavigasiUtama()),
        );
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                'Cari lowongan kerja impianmu di Yogyakarta!',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // EMAIL
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
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
              const SizedBox(height: 24),

              // TOMBOL LOGIN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Masuk',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: Text(
                  'Belum punya akun? Daftar disini',
                  style: GoogleFonts.poppins(color: Colors.indigo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}