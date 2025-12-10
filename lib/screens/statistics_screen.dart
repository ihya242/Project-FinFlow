import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/money_provider.dart';
import '../models/wallet.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Wallet? _selectedWallet; // Kalau null = Semua Dompet
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);
    final wallets = provider.wallets;
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // 1. SIAPKAN DATA (Filtering & Grouping)
    List<Map<String, double>> monthlyData = List.generate(
      12,
      (index) => {'income': 0, 'expense': 0},
    );

    Set<int> availableYears = {DateTime.now().year};

    for (var tx in provider.transactions) {
      availableYears.add(tx.date.year);

      // Filter Tahun (DIBUNGKUS { })
      if (tx.date.year != _selectedYear) {
        continue;
      }

      // Filter Wallet (DIBUNGKUS { })
      if (_selectedWallet != null && tx.walletId != _selectedWallet!.id) {
        continue;
      }

      // Masukkan ke slot bulan
      int monthIndex = tx.date.month - 1;
      if (tx.type == 'income') {
        monthlyData[monthIndex]['income'] =
            (monthlyData[monthIndex]['income'] ?? 0) + tx.amount;
      } else {
        monthlyData[monthIndex]['expense'] =
            (monthlyData[monthIndex]['expense'] ?? 0) + tx.amount;
      }
    }

    // Cari Insight
    double maxExpense = 0;
    int maxExpenseMonthIndex = 0;
    for (int i = 0; i < 12; i++) {
      if (monthlyData[i]['expense']! > maxExpense) {
        maxExpense = monthlyData[i]['expense']!;
        maxExpenseMonthIndex = i;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analisa Keuangan 📈"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FILTER SECTION ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Wallet?>(
                          value: _selectedWallet,
                          hint: const Text("Semua Dompet"),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Semua Dompet"),
                            ),
                            ...wallets.map(
                              (w) => DropdownMenuItem(
                                value: w,
                                child: Text(w.name),
                              ),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedWallet = val),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 20,
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        items: availableYears
                            .map(
                              (y) =>
                                  DropdownMenuItem(value: y, child: Text("$y")),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedYear = val!),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- 1. GRAFIK BATANG ---
            const Text(
              "Pemasukan vs Pengeluaran",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(monthlyData),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = rodIndex == 0 ? "Masuk" : "Keluar";
                        return BarTooltipItem(
                          "$label\n${NumberFormat.compact().format(rod.toY)}",
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'Mei',
                            'Jun',
                            'Jul',
                            'Agu',
                            'Sep',
                            'Okt',
                            'Nov',
                            'Des',
                          ];
                          if (value.toInt() >= 0 && value.toInt() < 12) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(12, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyData[index]['income']!,
                          color: Colors.teal,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: monthlyData[index]['expense']!,
                          color: Colors.redAccent,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Colors.teal, "Pemasukan"),
                const SizedBox(width: 20),
                _buildLegend(Colors.redAccent, "Pengeluaran"),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // --- 2. TRENDLINE ---
            const Text(
              "Trend Arus Kas (Net Flow)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Garis ini menunjukkan sisa uang (Masuk - Keluar) tiap bulan.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value <= 0) return const SizedBox.shrink();

                          final compactValue = NumberFormat.compact(
                            locale: 'id_ID',
                          ).format(value);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              compactValue,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'Mei',
                            'Jun',
                            'Jul',
                            'Agu',
                            'Sep',
                            'Okt',
                            'Nov',
                            'Des',
                          ];
                          if (value.toInt() >= 0 && value.toInt() < 12) {
                            return Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(12, (index) {
                        double net =
                            monthlyData[index]['income']! -
                            monthlyData[index]['expense']!;
                        return FlSpot(index.doubleValue, net);
                      }),
                      isCurved: true,
                      color: Colors.amber[700],
                      barWidth: 4,
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

            const SizedBox(height: 30),

            // --- INSIGHT CARD ---
            if (maxExpense > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Waspada Pengeluaran!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "Di tahun $_selectedYear, kamu paling boros di bulan ${DateFormat('MMMM', 'id_ID').format(DateTime(2024, maxExpenseMonthIndex + 1))} dengan total ${currency.format(maxExpense)}.",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(List<Map<String, double>> data) {
    double max = 0;
    for (var item in data) {
      // DIBUNGKUS { } BIAR LINTER SENANG
      if (item['income']! > max) {
        max = item['income']!;
      }
      if (item['expense']! > max) {
        max = item['expense']!;
      }
    }
    return max == 0 ? 100000 : max * 1.2;
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

extension IntExt on int {
  double get doubleValue => toDouble();
}
