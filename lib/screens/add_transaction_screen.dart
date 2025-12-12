import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_format.dart';
import '../providers/money_provider.dart';
import '../models/wallet.dart';
import '../models/transaction_template.dart';

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
  TransactionTemplate? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context, listen: false);
    final wallets = context.watch<MoneyProvider>().wallets;
    final templates = context.watch<MoneyProvider>().templates;

    if (_selectedWallet == null && wallets.isNotEmpty) {
      _selectedWallet = wallets.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text("CATAT TRANSAKSI"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.pinkAccent.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 2,
          color: Colors.white,
          shadows: [
            BoxShadow(
              color: Colors.pinkAccent.withValues(alpha: 0.8),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.pinkAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 0. SWITCH (Tetap di paling atas biar jelas tipe-nya)
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
                    "PENGELUARAN 💸",
                    Colors.redAccent,
                  ),
                  _buildSwitchButton(
                    'income',
                    "PEMASUKAN 💰",
                    Colors.greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 1. PILIH DOMPET (Urutan Pertama)
            _buildLabel("DOMPET SUMBER"),
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
                            AppFormat.compactCurrency(w.balance),
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

            // 2. PILIH TANGGAL (Urutan Kedua)
            _buildLabel("TANGGAL"),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Colors.pinkAccent,
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
                      AppFormat.dateFull(_selectedDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30), // Jarak agak jauh buat pemisah
            // 3. INPUT NOMINAL (Urutan Ketiga - Glowing Besar)
            Text(
              "JUMLAH UANG (NOMINAL)",
              style: TextStyle(
                color: _type == 'income'
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.left, // Balikin ke kiri biar rapi
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              // textAlign: TextAlign.center, // Boleh Center atau Left, kita coba Left biar urut
              style: TextStyle(
                color: Colors.white,
                fontSize: 32, // Sedikit diperkecil biar muat
                fontWeight: FontWeight.bold,
                shadows: [
                  BoxShadow(
                    color:
                        (_type == 'income'
                                ? Colors.greenAccent
                                : Colors.redAccent)
                            .withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              decoration: InputDecoration(
                prefixText: "Rp ",
                prefixStyle: TextStyle(
                  color: _type == 'income'
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                hintText: "0",
                hintStyle: TextStyle(color: Colors.grey.shade800, fontSize: 32),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: _type == 'income'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),

            const SizedBox(height: 30),

            // 4. KETERANGAN (Urutan Keempat)
            _buildLabel("KETERANGAN"),

            // Dropdown Template
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TransactionTemplate>(
                  value: _selectedTemplate,
                  hint: const Text(
                    "Pilih Template Cepat",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2C2C2C),
                  items: templates.map((TransactionTemplate item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Row(
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.type == 'income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (TransactionTemplate? val) {
                    setState(() {
                      _selectedTemplate = val;
                      if (val != null) {
                        _descController.text = val.title;
                        _type = val.type; // Auto ganti tipe
                      } else {
                        _descController.clear();
                      }
                    });
                  },
                ),
              ),
            ),

            // Input Manual
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
                  hintText: "Atau ketik manual...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.edit_note_rounded, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: _type == 'income'
                      ? [Colors.greenAccent, Colors.teal]
                      : [Colors.redAccent, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_type == 'income'
                                ? Colors.greenAccent
                                : Colors.redAccent)
                            .withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _processTransaction(provider),
                child: const Text(
                  "SIMPAN SEKARANG",
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.pinkAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
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
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ]
                : [],
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
    _saveToDatabase(provider);
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
