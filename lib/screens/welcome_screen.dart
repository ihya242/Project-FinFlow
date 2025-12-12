import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Gunakan Center & SingleChildScrollView biar aman di semua ukuran layar
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. LOGO
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    // Pastikan file assets/icon.png sudah ada ya
                    child: Image.asset(
                      'assets/icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Kalau gambar error/gak ada, tampilkan Icon Dompet
                        return const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 50,
                          color: Colors.teal,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Selamat Datang di\nFinFlow",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Kelola uangmu, wujudkan impianmu.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 50),

              // 2. INPUT NAMA
              const Text(
                "Siapa namamu?",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Contoh: Ihya",
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),

              const SizedBox(height: 40), // Ganti Spacer dengan Jarak Tetap
              // 3. TOMBOL LANJUT
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                  shadowColor: Colors.teal.withValues(alpha: 0.5),
                ),
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    Provider.of<MoneyProvider>(
                      context,
                      listen: false,
                    ).updateUserName(_nameController.text);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Isi nama panggilanmu dulu ya!"),
                      ),
                    );
                  }
                },
                child: const Text(
                  "MULAI SEKARANG 🚀",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
