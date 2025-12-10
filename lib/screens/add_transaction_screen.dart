import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/money_provider.dart';
import '../models/wallet.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String _type = 'expense';
  Wallet? _selectedWallet;
  DateTime _selectedDate = DateTime.now();

  // DAFTAR TEMPLATE (Update Terbaru)
  final List<String> _descriptionTemplates = [
    "Gaji per Month (G/M)", // <--- INI KHUSUS GAJI
    "Needs Monthly",
    "Invest Gold",
    "Makan & Minum",
    "Transport",
    "Topup E-Wallet",
    "Lainnya",
  ];

  String? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<MoneyProvider>(context, listen: false);
    final wallets = context.watch<MoneyProvider>().wallets;

    if (_selectedWallet == null && wallets.isNotEmpty) {
      _selectedWallet = wallets.first;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Catat Transaksi"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SWITCH NEON
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

            // 2. INPUT NOMINAL
            const Text(
              "Jumlah Uang",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixText: "Rp ",
                prefixStyle: TextStyle(
                  color: _type == 'income'
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 32,
                ),
                hintText: "0",
                hintStyle: TextStyle(color: Colors.grey.shade800, fontSize: 32),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.white24),

            const SizedBox(height: 30),

            // 3. PILIH DOMPET
            _buildLabel("Dompet Sumber"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Wallet>(
                  value: _selectedWallet,
                  dropdownColor: const Color(0xFF2C2C2C),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                  ),
                  items: wallets.map((w) {
                    return DropdownMenuItem(
                      value: w,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            w.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            NumberFormat.compact().format(w.balance),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedWallet = val),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4. PILIH TANGGAL
            _buildLabel("Tanggal"),
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
                if (picked != null) setState(() => _selectedDate = picked);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat(
                        'EEEE, dd MMMM yyyy',
                        'id_ID',
                      ).format(_selectedDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5. INPUT KETERANGAN (Updated Templates)
            _buildLabel("Keterangan / Kategori"),

            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTemplate,
                  hint: const Text(
                    "Pilih Template Cepat",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2C2C2C),
                  items: _descriptionTemplates.map((String item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTemplate = val;
                      if (val != null && !val.contains("Lainnya")) {
                        _descController.text = val;

                        // OTOMATIS GANTI TIPE KE PEMASUKAN KALAU PILIH GAJI
                        if (val.toLowerCase().contains("gaji")) {
                          _type = 'income';
                        }
                      } else {
                        _descController.clear();
                      }
                    });
                  },
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Atau ketik manual: 'G/M'",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.edit_note_rounded, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'income'
                      ? Colors.greenAccent.shade700
                      : Colors.redAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                onPressed: () => _processTransaction(provider),
                child: const Text(
                  "SIMPAN SEKARANG",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchButton(String value, String label, Color activeColor) {
    bool isSelected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
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

  void _processTransaction(MoneyProvider provider) {
    if (_amountController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data dulu ya sayang!")),
      );
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0;
    String desc = _descController.text
        .toLowerCase(); // Ubah ke huruf kecil biar gampang cek

    // LOGIKA BARU DETEKSI GAJI (G/M atau GAJI)
    if (_type == 'income' && (desc.contains('gaji') || desc.contains('g/m'))) {
      _showSalaryAllocationDialog(amount, provider);
    } else {
      _saveToDatabase(provider);
    }
  }

  void _showSalaryAllocationDialog(double totalGaji, MoneyProvider provider) {
    double danaDarurat = totalGaji * 0.30;
    double investEmas = totalGaji * 0.25;
    double sehariHari = totalGaji * 0.45;

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "🎉 Wah Gaji Masuk!",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sesuai instruksi Ihya (G/M), ini alokasinya:",
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(color: Colors.white24),
            _allocationRow("🛡️ Safe (30%)", danaDarurat, currency),
            _allocationRow("🥇 Invest (25%)", investEmas, currency),
            _allocationRow("🍜 Needs (45%)", sehariHari, currency),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveToDatabase(provider);
            },
            child: const Text("SIAP LAKSANAKAN!"),
          ),
        ],
      ),
    );
  }

  Widget _allocationRow(String title, double amount, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            fmt.format(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _saveToDatabase(MoneyProvider provider) async {
    await provider.addTransaction(
      type: _type,
      amount: double.parse(_amountController.text),
      category: _type == 'income' ? 'Pemasukan' : 'Pengeluaran',
      description: _descController.text,
      date: _selectedDate,
      wallet: _selectedWallet!,
    );
    if (mounted) Navigator.pop(context);
  }
}
