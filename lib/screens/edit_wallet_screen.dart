import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/money_provider.dart';

class EditWalletScreen extends StatefulWidget {
  final Wallet wallet;
  const EditWalletScreen({super.key, required this.wallet});

  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    // Isi otomatis dengan data lama
    _nameController = TextEditingController(text: widget.wallet.name);
    // Tampilkan saldo apa adanya (biar bisa dikoreksi manual)
    _balanceController = TextEditingController(
      text: widget.wallet.balance.toStringAsFixed(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Atur Dompet"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icon Besar
            Icon(
              Icons.settings_suggest_rounded,
              size: 80,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            const Text(
              "Koreksi nama atau saldo jika ada kesalahan.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // FORM EDIT
            _buildTextField(_nameController, "Nama Dompet", Icons.edit),
            const SizedBox(height: 20),
            _buildTextField(
              _balanceController,
              "Saldo Saat Ini",
              Icons.account_balance_wallet,
              isNumber: true,
            ),

            const SizedBox(height: 40),

            // TOMBOL UPDATE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // AKSI SIMPAN PERUBAHAN
                  final provider = Provider.of<MoneyProvider>(
                    context,
                    listen: false,
                  );
                  double newBal = double.tryParse(_balanceController.text) ?? 0;

                  provider.editWallet(
                    widget.wallet,
                    _nameController.text,
                    newBal,
                  );

                  Navigator.pop(context); // Tutup
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data dompet diperbarui! ✅")),
                  );
                },
                child: const Text("SIMPAN PERUBAHAN"),
              ),
            ),

            const SizedBox(height: 20),

            // TOMBOL HAPUS (Bahaya)
            TextButton.icon(
              onPressed: () {
                _showDeleteConfirmation(context);
              },
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              label: const Text(
                "Hapus Dompet Ini",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Hapus Dompet?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "⚠️ PERINGATAN:\nSemua riwayat transaksi di dalam dompet ini akan ikut TERHAPUS permanen.\n\nYakin mau lanjut?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              // AKSI HAPUS
              Provider.of<MoneyProvider>(
                context,
                listen: false,
              ).deleteWallet(widget.wallet.id);

              Navigator.pop(ctx); // Tutup Dialog
              Navigator.pop(context); // Tutup Halaman Edit
              Navigator.pop(context); // Tutup Halaman Detail (Balik ke Home)

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Dompet dan isinya telah dihapus. 🗑️"),
                ),
              );
            },
            child: const Text(
              "YA, HAPUS SEMUA",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
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
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
