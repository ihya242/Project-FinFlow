import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../providers/money_provider.dart';
import 'edit_transaction_screen.dart';
import 'edit_wallet_screen.dart';

class WalletDetailScreen extends StatefulWidget {
  final Wallet wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  DateTime _selectedDate = DateTime.now(); // Default pilih bulan ini

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final provider = Provider.of<MoneyProvider>(context);

    // 1. FILTER TRANSAKSI (Sesuai Wallet & Bulan yang dipilih)
    final monthlyTransactions = provider.transactions.where((tx) {
      return tx.walletId == widget.wallet.id &&
          tx.date.year == _selectedDate.year &&
          tx.date.month == _selectedDate.month;
    }).toList();

    // 2. HITUNG TOTAL BULAN INI (Buat Grafik)
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
      appBar: AppBar(
        title: Text(widget.wallet.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
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
            icon: const Icon(Icons.settings),
            tooltip: "Atur Dompet",
          ),
        ],
      ),
      body: Column(
        children: [
          // --- HEADER: SALDO UTAMA & NAVIGASI BULAN ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Saldo Saat Ini",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  currency.format(widget.wallet.balance),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // NAVIGASI BULAN (< Desember 2024 >)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            // Mundur 1 bulan
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            // Maju 1 bulan
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- GRAFIK BULANAN (Mini Pie Chart) ---
          if (monthlyTransactions.isNotEmpty) ...[
            const SizedBox(height: 20),
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
                          currency,
                        ),
                        const SizedBox(height: 10),
                        _buildLegend(
                          Colors.redAccent,
                          "Keluar",
                          expenseMonth,
                          currency,
                        ),
                        const Divider(),
                        Text(
                          "Sisa: ${currency.format(incomeMonth - expenseMonth)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Kalau bulan ini kosong
            const SizedBox(height: 30),
            const Text(
              "Belum ada transaksi bulan ini 💤",
              style: TextStyle(color: Colors.grey),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(),

          // --- LIST TRANSAKSI BULAN INI ---
          Expanded(
            child: monthlyTransactions.isEmpty
                ? const SizedBox() // Udah ada teks di atas
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: monthlyTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = monthlyTransactions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: tx.type == 'income'
                              ? Colors.green[50]
                              : Colors.red[50],
                          child: Icon(
                            tx.type == 'income'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: tx.type == 'income'
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.category,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${DateFormat('dd MMM').format(tx.date)} • ${tx.description}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          currency.format(tx.amount),
                          style: TextStyle(
                            color: tx.type == 'income'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // Fitur Edit tetep jalan dong!
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditTransactionScreen(transaction: tx),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    Color color,
    String label,
    double amount,
    NumberFormat fmt,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
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
              fmt.format(amount),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
