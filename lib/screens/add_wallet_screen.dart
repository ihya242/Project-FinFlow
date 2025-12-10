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
    // Ambil warna tema biar konsisten
    final theme = Theme.of(context);

    return Scaffold(
      // Background Gelap
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tambah Dompet Baru"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ikon Besar di Tengah
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Buat rekening atau pos penyimpanan baru.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 1. INPUT NAMA DOMPET
            _buildTextField(
              controller: _nameController,
              label: "Nama Dompet",
              hint: "Contoh: Tabungan Nikah, OVO",
              icon: Icons.edit,
            ),

            const SizedBox(height: 20),

            // 2. INPUT SALDO AWAL
            _buildTextField(
              controller: _balanceController,
              label: "Saldo Awal",
              hint: "0",
              icon: Icons.monetization_on_rounded,
              isNumber: true,
              prefix: "Rp ",
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN MODERN
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary, // Warna Pink Tema
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  double balance =
                      double.tryParse(_balanceController.text) ?? 0;

                  Provider.of<MoneyProvider>(
                    context,
                    listen: false,
                  ).addWallet(_nameController.text, balance);

                  Navigator.pop(context); // Balik ke Home

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Dompet berhasil dibuat! 🎉")),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget TextField Custom biar Rapi & Teksnya PUTIH
  Widget _buildTextField({
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
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Warna Card Gelap
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(
              color: Colors.white,
            ), // <--- INI SOLUSINYA! (TEKS JADI PUTIH)
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade700),
              prefixText: prefix,
              prefixStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(icon, color: Colors.grey),
              border: InputBorder.none, // Hilangkan border bawaan
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
