import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/money_provider.dart';
import '../utils/app_format.dart'; // ✅ Pakai Utils
import 'edit_transaction_screen.dart'; // ✅ Fitur Edit Transaksi Kembali
import 'edit_wallet_screen.dart'; // ✅ Fitur Setting Wallet Kembali

class WalletDetailScreen extends StatefulWidget {
  final Wallet wallet;
  const WalletDetailScreen({super.key, required this.wallet});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  DateTime _selectedDate = DateTime.now(); // Filter Bulan Aktif

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);

    // 1. FILTER TRANSAKSI (Logic Lama yang Pintar)
    // Kita filter berdasarkan Wallet ID DAN Bulan/Tahun yang dipilih
    final monthlyTransactions = provider.transactions.where((tx) {
      return tx.walletId == widget.wallet.id &&
          tx.date.year == _selectedDate.year &&
          tx.date.month == _selectedDate.month;
    }).toList();

    // 2. HITUNG TOTAL BULAN INI (Buat Grafik Pie)
    double incomeMonth = 0;
    double expenseMonth = 0;
    for (var tx in monthlyTransactions) {
      if (tx.type == 'income') {
        incomeMonth += tx.amount;
      } else {
        expenseMonth += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background Hitam Pekat
      // --- APPBAR GLOWING CYAN (Khas Menu Wallet) ---
      appBar: AppBar(
        title: Text(widget.wallet.name.toUpperCase()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        // Dekorasi Gradient & Glow
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

        // TOMBOL SETTING (DIPULIHKAN ✅)
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditWalletScreen(wallet: widget.wallet),
                ),
              );
            },
            icon: const Icon(Icons.settings_rounded, color: Colors.cyanAccent),
            tooltip: "Atur Dompet",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KARTU SALDO & NAVIGASI BULAN (Modern Style) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2C2C2C), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Saldo Saat Ini",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  // Saldo Utama
                  Text(
                    AppFormat.currency(widget.wallet.balance),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 10),

                  // NAVIGASI BULAN (< Desember 2025 >) - DIPULIHKAN ✅
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.cyanAccent,
                        ),
                        onPressed: () => setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month - 1,
                          );
                        }),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppFormat.monthYear(_selectedDate),
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.cyanAccent,
                        ),
                        onPressed: () => setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month + 1,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- GRAFIK PIE & SUMMARY (DIPULIHKAN ✅) ---
            if (monthlyTransactions.isNotEmpty) ...[
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    // GRAFIK
                    Expanded(
                      flex: 1,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            if (expenseMonth > 0)
                              PieChartSectionData(
                                color: Colors.redAccent,
                                value: expenseMonth,
                                title: '',
                                radius: 40,
                              ),
                            if (incomeMonth > 0)
                              PieChartSectionData(
                                color: Colors.greenAccent,
                                value: incomeMonth,
                                title: '',
                                radius: 40,
                              ),
                          ],
                        ),
                      ),
                    ),
                    // KETERANGAN (Legend)
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegend(
                            Colors.greenAccent,
                            "Masuk",
                            incomeMonth,
                          ),
                          const SizedBox(height: 10),
                          _buildLegend(
                            Colors.redAccent,
                            "Keluar",
                            expenseMonth,
                          ),
                          const Divider(color: Colors.white10),
                          Text(
                            "Net: ${AppFormat.currency(incomeMonth - expenseMonth)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Kalau kosong bulan ini
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Belum ada transaksi bulan ini 💤",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat ${AppFormat.monthYear(_selectedDate)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- LIST TRANSAKSI (FITUR EDIT DIPULIHKAN ✅) ---
            monthlyTransactions.isEmpty
                ? const SizedBox() // Sudah ada teks di atas
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: monthlyTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = monthlyTransactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: tx.type == 'income'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tx.type == 'income'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: tx.type == 'income'
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            tx.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "${AppFormat.dateShort(tx.date)} • ${tx.description}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            AppFormat.currency(tx.amount),
                            style: TextStyle(
                              color: tx.type == 'income'
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            // NAVIGASI KE EDIT TRANSAKSI ✅
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditTransactionScreen(transaction: tx),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label, double amount) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              AppFormat.currency(amount),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
