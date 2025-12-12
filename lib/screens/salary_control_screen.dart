import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/money_provider.dart';
import '../models/wallet.dart';

// 👇 IMPORT BARU KITA
import '../utils/app_format.dart';
import '../widgets/evolution_card.dart';

class SalaryControlScreen extends StatefulWidget {
  const SalaryControlScreen({super.key});

  @override
  State<SalaryControlScreen> createState() => _SalaryControlScreenState();
}

class _SalaryControlScreenState extends State<SalaryControlScreen> {
  String? _needsWalletId;
  String? _safeWalletId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    var box = await Hive.openBox('settings');
    setState(() {
      _needsWalletId = box.get('needs_wallet_id');
      _safeWalletId = box.get('safe_wallet_id');
    });
  }

  void _saveSettings(String key, String? walletId) async {
    var box = await Hive.openBox('settings');
    await box.put(key, walletId);
    setState(() {
      if (key == 'needs_wallet_id') _needsWalletId = walletId;
      if (key == 'safe_wallet_id') _safeWalletId = walletId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);
    final wallets = provider.wallets;
    // final currency = ... (SUDAH DIHAPUS, GANTI AppFormat)
    final now = DateTime.now();

    // 🧠 1. HITUNG GAJI (Logic sama)
    double totalSalaryThisMonth = 0;
    for (var tx in provider.transactions) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        if (tx.type == 'income') {
          String desc = tx.description.toLowerCase();
          if (desc.contains('gaji') || desc.contains('g/m')) {
            totalSalaryThisMonth += tx.amount;
          }
        }
      }
    }

    // 🧠 2. LOGIKA NEEDS
    double needsBudget = 0;
    double needsRealBalance = 0;
    double needsUsable = 0;
    if (_needsWalletId != null) {
      try {
        final w = wallets.firstWhere((w) => w.id == _needsWalletId);
        needsRealBalance = w.balance;
        needsUsable = (needsRealBalance - 50000) < 0
            ? 0
            : (needsRealBalance - 50000);
        // ignore: empty_catches
      } catch (e) {}
    }
    for (var tx in provider.transactions) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        if (_needsWalletId != null && tx.walletId == _needsWalletId) {
          if (tx.type == 'income' &&
              tx.description.toLowerCase().contains('needs monthly')) {
            needsBudget += tx.amount;
          }
        }
      }
    }
    double needsPercent = needsBudget == 0 ? 0 : needsUsable / needsBudget;
    if (needsPercent > 1) needsPercent = 1;

    // 🧠 3. LOGIKA INVEST
    double investTarget = totalSalaryThisMonth * 0.25;
    double investCollected = 0;
    for (var tx in provider.transactions) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        if (tx.type == 'expense') {
          String desc = tx.description.toLowerCase();
          if (desc.contains('invest') ||
              desc.contains('gold') ||
              desc.contains('emas')) {
            investCollected += tx.amount;
          }
        }
      }
    }
    double investPercent = investTarget == 0
        ? 0
        : investCollected / investTarget;
    if (investPercent > 1) investPercent = 1;

    // 🧠 4. LOGIKA SAFE
    double safeTargetMonthly = totalSalaryThisMonth * 0.30;
    double safeTotalBalance = 0;
    Wallet? safeWalletObj;
    if (_safeWalletId != null) {
      try {
        safeWalletObj = wallets.firstWhere((w) => w.id == _safeWalletId);
        safeTotalBalance = safeWalletObj.balance;
        // ignore: empty_catches
      } catch (e) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("CONTROL CENTER"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal.withValues(alpha: 0.15), Colors.transparent],
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
              color: Colors.tealAccent.withValues(alpha: 0.8),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER INFO (Gaji) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.shade900.withValues(alpha: 0.4),
                    Colors.black,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PERIODE: ${DateFormat('MMMM yyyy', 'id_ID').format(now).toUpperCase()}",
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // PAKAI AppFormat DISINI 👇
                      Text(
                        AppFormat.currency(totalSalaryThisMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.radar_rounded,
                      color: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ============================================
            // 1. MODULE NEEDS (Pakai EvolutionCard dari widgets)
            // ============================================
            EvolutionCard(
              color: Colors.greenAccent,
              icon: Icons.bolt_rounded,
              title: "Daily Energy",
              subtitle: "Needs / Uang Jajan",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // PAKAI AppFormat DISINI 👇
                      Text(
                        AppFormat.currency(needsUsable),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: Colors.greenAccent.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        color: const Color(0xFF2C2C2C),
                        onSelected: (val) =>
                            _saveSettings('needs_wallet_id', val),
                        itemBuilder: (context) => wallets
                            .map(
                              (w) => PopupMenuItem(
                                value: w.id,
                                child: Text(
                                  w.name,
                                  style: TextStyle(
                                    color: w.id == _needsWalletId
                                        ? Colors.greenAccent
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "dari kapasitas ${AppFormat.currency(needsBudget)}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),

                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: needsPercent,
                      minHeight: 12,
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      color: needsPercent < 0.2
                          ? Colors.redAccent
                          : Colors.greenAccent,
                    ),
                  ),
                  if (_needsWalletId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_clock,
                            size: 12,
                            color: Colors.white30,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Safety Lock: 50k active",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // 2. MODULE INVEST
            // ============================================
            EvolutionCard(
              color: Colors.amber,
              icon: Icons.rocket_launch_rounded,
              title: "Growth Engine",
              subtitle: "Invest / Emas",
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppFormat.currency(investCollected),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "collected",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFormat.currency(investTarget),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          Text(
                            "target",
                            style: TextStyle(
                              color: Colors.amber.withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: 8,
                        width:
                            MediaQuery.of(context).size.width *
                            0.8 *
                            investPercent,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // 3. MODULE SAFE
            // ============================================
            EvolutionCard(
              color: Colors.cyanAccent,
              icon: Icons.shield_rounded,
              title: "The Vault",
              subtitle: "Safe / Darurat",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _safeWalletId == null
                            ? "Not Connected"
                            : AppFormat.currency(safeTotalBalance),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _safeWalletId == null
                              ? Colors.grey
                              : Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.settings_input_component_rounded,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                        color: const Color(0xFF2C2C2C),
                        onSelected: (val) =>
                            _saveSettings('safe_wallet_id', val),
                        itemBuilder: (context) => wallets
                            .where((w) => w.id != _needsWalletId)
                            .map(
                              (w) => PopupMenuItem(
                                value: w.id,
                                child: Text(
                                  w.name,
                                  style: TextStyle(
                                    color: w.id == _safeWalletId
                                        ? Colors.cyanAccent
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Monthly Mission: +${AppFormat.currency(safeTargetMonthly)}",
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: (_safeWalletId == null || safeWalletObj == null)
                        ? null
                        : () => _showEmergencyDialog(context, safeWalletObj!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "EMERGENCY WITHDRAWAL",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- DIALOG DARURAT (Tidak berubah) ---
  void _showEmergencyDialog(BuildContext context, Wallet safeWallet) {
    // ... (Logika Dialog Sama Persis dengan sebelumnya) ...
    // Cukup copy bagian dialog dari kode sebelumnya ya!
    // Atau kalau mau Onee-chan tuliskan lagi di sini? (Biar hemat tempat, pakai yang lama saja isinya sama)

    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              "EMERGENCY",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Dana ini untuk masa depan. Pastikan benar-benar darurat.",
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nominal",
                labelStyle: TextStyle(color: Colors.grey),
                prefixText: "Rp ",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Alasan",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              if (amountController.text.isNotEmpty &&
                  reasonController.text.isNotEmpty) {
                Provider.of<MoneyProvider>(
                  context,
                  listen: false,
                ).addTransaction(
                  type: 'expense',
                  amount: double.parse(amountController.text),
                  category: 'Darurat',
                  description: "DARURAT: ${reasonController.text}",
                  date: DateTime.now(),
                  wallet: safeWallet,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Dana Darurat dicairkan.")),
                );
              }
            },
            child: const Text("CAIRKAN"),
          ),
        ],
      ),
    );
  }
}
