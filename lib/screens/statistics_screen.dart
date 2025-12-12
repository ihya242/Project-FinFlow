import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';
import '../models/wallet.dart';
import '../utils/app_format.dart'; // <--- IMPORT UTILS KITA 🛠️

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedYear = DateTime.now().year;
  Wallet? _selectedWallet;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text("ANALISA DATA"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purpleAccent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 2,
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.purpleAccent.withValues(alpha: 0.8),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.purpleAccent,
            indicatorWeight: 3,
            labelColor: Colors.purpleAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart_rounded), text: "KOMPARASI"),
              Tab(icon: Icon(Icons.show_chart_rounded), text: "ARUS KAS"),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildBarChartSection(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildLineChartSection(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final provider = Provider.of<MoneyProvider>(context);
    List<int> years = provider.transactions
        .map((e) => e.date.year)
        .toSet()
        .toList();
    years.sort();
    if (!years.contains(DateTime.now().year)) years.add(DateTime.now().year);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  dropdownColor: const Color(0xFF2C2C2C),
                  isExpanded: true,
                  items: years
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text(
                            y.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedYear = val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Wallet?>(
                  value: _selectedWallet,
                  dropdownColor: const Color(0xFF2C2C2C),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<Wallet?>(
                      value: null,
                      child: Text(
                        "Semua Dompet",
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                    ...provider.wallets.map(
                      (w) => DropdownMenuItem(
                        value: w,
                        child: Text(
                          w.name,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedWallet = val),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. GRAFIK BATANG ---
  Widget _buildBarChartSection(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);
    // HAPUS NumberFormat Manual

    double totalIncomeYear = 0;
    double totalExpenseYear = 0;

    List<double> incomePerMonth = List.filled(12, 0.0);
    List<double> expensePerMonth = List.filled(12, 0.0);

    for (var tx in provider.transactions) {
      if (tx.date.year != _selectedYear) continue;
      if (_selectedWallet != null && tx.walletId != _selectedWallet!.id) {
        continue;
      }

      String desc = tx.description.toLowerCase();
      if (desc.contains('transfer') || desc.contains('pindah')) continue;

      if (tx.type == 'income') {
        incomePerMonth[tx.date.month - 1] += tx.amount;
        totalIncomeYear += tx.amount;
      } else {
        expensePerMonth[tx.date.month - 1] += tx.amount;
        totalExpenseYear += tx.amount;
      }
    }

    double maxY = 0;
    for (var i = 0; i < 12; i++) {
      if (incomePerMonth[i] > maxY) maxY = incomePerMonth[i];
      if (expensePerMonth[i] > maxY) maxY = expensePerMonth[i];
    }
    if (maxY == 0) maxY = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(Colors.tealAccent, "Pemasukan"),
            const SizedBox(width: 20),
            _buildLegend(Colors.redAccent, "Pengeluaran"),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (v, m) {
                      if (v == 0) return const SizedBox.shrink();
                      // 👇 PAKAI UTILS COMPACT (misal: 1jt)
                      return Text(
                        AppFormat.compactCurrency(v),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      const months = [
                        'J',
                        'F',
                        'M',
                        'A',
                        'M',
                        'J',
                        'J',
                        'A',
                        'S',
                        'O',
                        'N',
                        'D',
                      ];
                      if (v.toInt() >= 0 && v.toInt() < 12) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[v.toInt()],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10),
              ),
              barGroups: List.generate(
                12,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: incomePerMonth[i],
                      color: Colors.tealAccent,
                      width: 6,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    BarChartRodData(
                      toY: expensePerMonth[i],
                      color: Colors.redAccent,
                      width: 6,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        _buildWarningCard(totalIncomeYear, totalExpenseYear),
      ],
    );
  }

  // --- 2. GRAFIK GARIS ---
  Widget _buildLineChartSection(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);

    List<FlSpot> spots = [];
    double minNet = 0;
    double maxNet = 0;

    for (int i = 1; i <= 12; i++) {
      double income = 0;
      double expense = 0;

      for (var tx in provider.transactions) {
        if (tx.date.year != _selectedYear) continue;
        if (_selectedWallet != null && tx.walletId != _selectedWallet!.id) {
          continue;
        }
        if (tx.date.month == i) {
          if (tx.description.toLowerCase().contains('transfer') ||
              tx.description.toLowerCase().contains('pindah')) {
            continue;
          }
          if (tx.type == 'income') {
            income += tx.amount;
          } else {
            expense += tx.amount;
          }
        }
      }
      double net = income - expense;
      spots.add(FlSpot(i - 1.0, net));
      if (net < minNet) minNet = net;
      if (net > maxNet) maxNet = net;
    }
    if (maxNet == 0 && minNet == 0) maxNet = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Net Flow (Sisa)",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: minNet * 1.2,
              maxY: maxNet * 1.2,
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (v, m) {
                      if (v == 0) return const SizedBox.shrink();
                      // 👇 PAKAI UTILS COMPACT
                      return Text(
                        AppFormat.compactCurrency(v),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      const months = [
                        'J',
                        'F',
                        'M',
                        'A',
                        'M',
                        'J',
                        'J',
                        'A',
                        'S',
                        'O',
                        'N',
                        'D',
                      ];
                      if (v.toInt() >= 0 && v.toInt() < 12) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[v.toInt()],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.amber,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 WIDGET PERINGATAN 🔥
  Widget _buildWarningCard(double totalIncome, double totalExpense) {
    double ratio = totalIncome == 0 ? 0 : totalExpense / totalIncome;

    if (ratio < 0.8) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3E1F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Waspada Pengeluaran!",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  // 👇 PAKAI UTILS CURRENCY
                  "Tahun ini kamu sudah menghabiskan ${(ratio * 100).toStringAsFixed(0)}% dari pemasukan.\nTotal Keluar: ${AppFormat.currency(totalExpense)}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
