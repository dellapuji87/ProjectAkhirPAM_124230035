import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:lokerin/screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/read_screen.dart';
import 'model/job.dart';
import 'services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

// === GENERATE KEY ENKRIPSI AES-256 (PAKAI crypto) ===
Future<Uint8List> getEncryptionKey() async {
  final keyBox = await Hive.openBox('encryption_key_box');
  
  if (keyBox.containsKey('aes_key')) {
    final encodedKey = keyBox.get('aes_key') as String;
    return base64Url.decode(encodedKey);
  } else {
    final random = Random.secure();
    final key = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      key[i] = random.nextInt(256);
    }
    await keyBox.put('aes_key', base64Url.encode(key));
    return key;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(JobAdapter());

  await Hive.openBox('session');
  await Hive.openBox('favorit');

  // ENKRIPSI BOX 'users'
  final encryptionKey = await getEncryptionKey();
  await Hive.openBox('users', encryptionCipher: HiveAesCipher(encryptionKey));

  await NotificationService().initialize();

  runApp(const AplikasiLokerin());
}

class AplikasiLokerin extends StatelessWidget {
  const AplikasiLokerin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LokerIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.poppins(),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const NavigasiUtama(),
        '/intro': (context) => const IntroScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final sessionBox = Hive.box('session');
    final isLoggedIn = sessionBox.get('loggedIn', defaultValue: false);

    await Future.delayed(const Duration(seconds: 2)); // Animasi splash

    if (mounted) {
      if (isLoggedIn) {
        // LANGSUNG KE HOME
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // KE INTRO → LALU LOGIN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IntroScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'LokerIn',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}



class NavigasiUtama extends StatefulWidget {
  const NavigasiUtama({super.key});
  @override
  State<NavigasiUtama> createState() => _NavigasiUtamaState();
}

class _NavigasiUtamaState extends State<NavigasiUtama> {
  int _indeks = 0;

  final List<Widget> _layar = [
    const LayarBeranda(),
    const LayarBaca(),
    const LayarFavorit(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _layar[_indeks],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _indeks,
        onTap: (i) => setState(() => _indeks = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Lowongan'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Tips'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}