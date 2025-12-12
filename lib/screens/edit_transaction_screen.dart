import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/money_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _descController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedType; // Variabel buat nampung Tipe (Income/Expense)

  @override
  void initState() {
    super.initState();
    // Isi data awal dari transaksi lama
    _descController = TextEditingController(
      text: widget.transaction.description,
    );
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(0),
    );
    _selectedDate = widget.transaction.date;
    _selectedType = widget.transaction.type; // Load tipe lama
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<MoneyProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Transaksi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SWITCH NEON (BISA DIGANTI SEKARANG!) 🟢🔴
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  _buildSwitchButton(
                    'expense',
                    "Pengeluaran 💸",
                    Colors.redAccent,
                  ),
                  _buildSwitchButton(
                    'income',
                    "Pemasukan 💰",
                    Colors.greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. EDIT TANGGAL (SUDAH BISA DIKLIK) 📅
            const Text(
              "Tanggal Transaksi",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: theme.colorScheme.primary,
                      ),
                    ),
                    child: child!,
                  ),
                );
                // UPDATE TANGGAL KALAU DIPILIH
                if (picked != null) setState(() => _selectedDate = picked);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat(
                        'EEEE, dd MMMM yyyy',
                        'id_ID',
                      ).format(_selectedDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, color: Colors.grey, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. EDIT KETERANGAN
            const Text(
              "Keterangan",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // 4. EDIT NOMINAL (Sekarang Boleh Diedit karena Provider sudah Canggih)
            const Text(
              "Nominal (Rp)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: _selectedType == 'income'
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixText: "Rp ",
                prefixStyle: TextStyle(
                  color: _selectedType == 'income'
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 24,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == 'income'
                      ? Colors.greenAccent.shade700
                      : Colors.redAccent.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Validasi
                  double? newAmount = double.tryParse(_amountController.text);
                  if (newAmount == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal harus angka ya!")),
                    );
                    return;
                  }

                  // PANGGIL FUNGSI EDIT YANG BARU
                  provider.editTransaction(
                    widget.transaction,
                    newType: _selectedType, // Tipe Baru
                    newAmount: newAmount, // Nominal Baru
                    newDescription: _descController.text,
                    newDate: _selectedDate, // Tanggal Baru
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Transaksi berhasil di-update! ✨"),
                    ),
                  );
                },
                child: const Text(
                  "SIMPAN PERUBAHAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Switch (Sama kayak di Add Screen)
  Widget _buildSwitchButton(String value, String label, Color activeColor) {
    bool isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _selectedType = value), // Ubah State saat diklik
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MoneyProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Hapus Transaksi?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Saldo dompet akan dikembalikan seperti sebelum transaksi ini terjadi.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.deleteTransaction(widget.transaction);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Transaksi dihapus.")),
              );
            },
            child: const Text("HAPUS"),
          ),
        ],
      ),
    );
  }
}
