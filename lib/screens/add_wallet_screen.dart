import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Hitam Pekat
      backgroundColor: const Color(0xFF121212),

      // --- APPBAR GLOWING CYAN ---
      appBar: AppBar(
        title: const Text("TAMBAH DOMPET"), // Uppercase biar tegas
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Gradient Header
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.cyanAccent.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Teks Glowing
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 2,
          color: Colors.white,
          shadows: [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.8),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.cyanAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // --- 1. IKON BESAR GLOWING ---
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1E1E),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 50,
                  color: Colors.cyanAccent,
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Buat pos penyimpanan baru untuk\nmengatur uangmu lebih rapi.",
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // --- 2. INPUT NAMA DOMPET ---
            _buildNeonTextField(
              controller: _nameController,
              label: "NAMA DOMPET",
              hint: "Contoh: Tabungan Nikah, OVO",
              icon: Icons.edit,
            ),

            const SizedBox(height: 25),

            // --- 3. INPUT SALDO AWAL ---
            _buildNeonTextField(
              controller: _balanceController,
              label: "SALDO AWAL",
              hint: "0",
              icon: Icons.monetization_on_rounded,
              isNumber: true,
              prefix: "Rp ",
            ),

            const SizedBox(height: 50),

            // --- 4. TOMBOL SIMPAN GRADIENT ---
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Colors.cyan, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.transparent, // Biar gradient tembus
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    double balance =
                        double.tryParse(_balanceController.text) ?? 0;

                    Provider.of<MoneyProvider>(
                      context,
                      listen: false,
                    ).addWallet(_nameController.text, balance);

                    Navigator.pop(context); // Balik

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Dompet berhasil dibuat! 🚀"),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nama dompet wajib diisi ya!"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text(
                  "SIMPAN DOMPET",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 WIDGET INPUT NEON 🔥
  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.cyanAccent, // Label warna Cyan
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          cursorColor: Colors.cyanAccent, // Kursor Cyan
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E1E), // Warna isi gelap
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade700),
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            prefixIcon: Icon(icon, color: Colors.grey),

            // Border Biasa (Abu Tipis)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),

            // Border Fokus (MENYALA CYAN) ✨
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}
