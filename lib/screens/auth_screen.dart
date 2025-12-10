import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';
import 'main_screen.dart'; // Pastikan ke MainScreen

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _pin = "";
  String _storedPin = "";
  bool _isRegistered = false;
  String _message = "Masukkan PIN Anda";

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  void _checkRegistration() async {
    var box = await Hive.openBox('settings');
    String? savedPin = box.get('user_pin');

    if (!mounted) return;

    setState(() {
      if (savedPin != null) {
        _isRegistered = true;
        _storedPin = savedPin;
        _message = "Selamat Datang Kembali! 🔒";
        Future.delayed(
          const Duration(milliseconds: 500),
          _authenticateBiometric,
        );
      } else {
        _isRegistered = false;
        _message = "Buat PIN Keamanan Baru 🆕";
      }
    });
  }

  Future<void> _authenticateBiometric() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Scan sidik jari untuk masuk',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (!mounted) return;
        if (didAuthenticate) _goToHome();
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
    }
  }

  void _onKeyPress(String val) {
    if (_pin.length < 6) {
      setState(() => _pin += val);
      if (_pin.length == 6) _validatePin();
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _validatePin() async {
    if (_isRegistered) {
      if (_pin == _storedPin) {
        _goToHome();
      } else {
        setState(() {
          _message = "PIN Salah! Coba lagi ❌";
          _pin = "";
        });
      }
    } else {
      var box = await Hive.openBox('settings');
      await box.put('user_pin', _pin);
      if (!mounted) return;
      setState(() {
        _isRegistered = true;
        _storedPin = _pin;
        _pin = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN Berhasil Disimpan! Silakan Login.")),
      );
      _message = "Masukkan PIN Anda";
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna dari tema biar konsisten
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; // Warna Pink
    final surfaceColor = theme.colorScheme.surface; // Warna Gelap Card

    return Scaffold(
      // Background Gelap dengan sedikit gradasi biar mewah
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF2C2C2C), theme.scaffoldBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Ikon Gembok dengan warna gradasi
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [primaryColor, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),
              Text(
                _message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Indikator PIN Modern
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Kalau terisi warna Pink, kalau kosong warna abu gelap
                      color: index < _pin.length
                          ? primaryColor
                          : Colors.grey.shade800,
                      boxShadow: index < _pin.length
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Keypad Container Gelap
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: surfaceColor, // Warna gelap
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildNumRow(['1', '2', '3']),
                    _buildNumRow(['4', '5', '6']),
                    _buildNumRow(['7', '8', '9']),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Tombol Fingerprint
                          IconButton(
                            onPressed: _isRegistered
                                ? _authenticateBiometric
                                : null,
                            icon: Icon(
                              Icons.fingerprint_rounded,
                              size: 45,
                              color: _isRegistered
                                  ? primaryColor
                                  : Colors.grey.shade700,
                            ),
                          ),
                          _buildNumBtn('0'),
                          // Tombol Hapus
                          IconButton(
                            onPressed: _onDelete,
                            icon: const Icon(
                              Icons.backspace_rounded,
                              size: 30,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumRow(List<String> numbers) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers.map((n) => _buildNumBtn(n)).toList(),
      ),
    );
  }

  Widget _buildNumBtn(String val) {
    return InkWell(
      onTap: () => _onKeyPress(val),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 75,
        height: 75,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade900, // Tombol warna gelap
        ),
        child: Text(
          val,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
