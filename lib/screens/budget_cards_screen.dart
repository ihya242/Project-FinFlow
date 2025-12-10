import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Butuh Hive buat simpan setting
import '../providers/money_provider.dart';
import '../models/wallet.dart';

class BudgetCardsScreen extends StatefulWidget {
  const BudgetCardsScreen({super.key});

  @override
  State<BudgetCardsScreen> createState() => _BudgetCardsScreenState();
}

class _BudgetCardsScreenState extends State<BudgetCardsScreen> {
  String? _safeWalletId; // ID Dompet yang dipilih sebagai Safe

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    var box = await Hive.openBox('settings');
    setState(() {
      _safeWalletId = box.get('safe_wallet_id');
    });
  }

  void _setSafeWallet(String id) async {
    var box = await Hive.openBox('settings');
    await box.put('safe_wallet_id', id);
    setState(() {
      _safeWalletId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final now = DateTime.now();

    // 1. DATA BULAN INI
    final thisMonthTx = provider.transactions
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();

    // --- A. HITUNG GAJI BERSIH (Income Base) ---
    // Hanya hitung yang labelnya "Gaji" atau "G/M".
    // Pemasukan lain (bonus kecil/nemu uang) TIDAK mempengaruhi target wajib 30-25-45.
    double totalGaji = 0;
    for (var tx in thisMonthTx) {
      if (tx.type == 'income') {
        String desc = tx.description.toLowerCase();
        if (desc.contains('gaji') || desc.contains('g/m')) {
          totalGaji += tx.amount;
        }
      }
    }
    double baseIncome = totalGaji == 0 ? 1 : totalGaji; // Cegah error bagi 0

    // --- B. HITUNG REALISASI ---
    double actualInvest = 0;
    double actualNeeds = 0;

    for (var tx in thisMonthTx) {
      if (tx.type == 'expense') {
        String desc = tx.description.toLowerCase();

        // Skip Transfer
        if (desc.contains('transfer') ||
            desc.contains('pindah') ||
            desc.contains('needs monthly')) {
          continue;
        }

        // Cek Invest
        if (desc.contains('gold') ||
            desc.contains('emas') ||
            desc.contains('invest')) {
          actualInvest += tx.amount;
        } else {
          // Sisanya Jajan/Needs
          actualNeeds += tx.amount;
        }
      }
    }

    // --- C. CEK SALDO SAFE (REAL) ---
    // Cari dompet yang dipilih sebagai Safe
    Wallet? safeWallet;
    if (_safeWalletId != null) {
      try {
        safeWallet = provider.wallets.firstWhere((w) => w.id == _safeWalletId);
      } catch (e) {
        // Kalau dompetnya dihapus user, reset setting
        _safeWalletId = null;
      }
    }

    // Saldo Safe adalah Saldo Real dompet tersebut
    double actualSafe = safeWallet?.balance ?? 0;

    // --- D. TARGET ---
    double targetInvest = baseIncome * 0.25;
    double limitNeeds = baseIncome * 0.45;
    double targetSafe = baseIncome * 0.30;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Kontrol Gaji 🎯"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Pilih Dompet Safe",
            onPressed: () => _showWalletSelector(context, provider.wallets),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(now, totalGaji, currency),

          const SizedBox(height: 30),

          // 1. NEEDS (Jajan)
          _buildBudgetCard(
            title: "Needs (Uang Jajan)",
            icon: Icons.shopping_bag_rounded,
            color: Colors.blueAccent,
            current: actualNeeds,
            target: limitNeeds,
            isExpenseLimit: true,
            desc: "Max 45% dari Gaji Utama",
          ),

          const SizedBox(height: 20),

          // 2. INVEST (Emas)
          _buildBudgetCard(
            title: "Invest Gold",
            icon: Icons.workspace_premium_rounded,
            color: Colors.amber,
            current: actualInvest,
            target: targetInvest,
            isExpenseLimit: false,
            desc: "Target 25% dari Gaji Utama",
          ),

          const SizedBox(height: 20),

          // 3. SAFE (Dompet Khusus)
          safeWallet == null
              ? _buildNoSafeWalletCard() // Tampilan kalau belum pilih dompet
              : _buildSafeCard(
                  title:
                      "Safe (${safeWallet.name})", // Munculkan nama dompetnya
                  current: actualSafe,
                  target: targetSafe,
                  currency: currency,
                ),
        ],
      ),
    );
  }

  // Pop Up Pilih Dompet Safe
  void _showWalletSelector(BuildContext context, List<Wallet> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Rekening Safe / Tabungan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...wallets.map(
                (w) => ListTile(
                  leading: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.teal,
                  ),
                  title: Text(
                    w.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: w.id == _safeWalletId
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    _setSafeWallet(w.id);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoSafeWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          const Text(
            "Dompet Safe Belum Dipilih!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Pilih rekening mana yang jadi tabunganmu.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _showWalletSelector(
              context,
              Provider.of<MoneyProvider>(context, listen: false).wallets,
            ),
            child: const Text("Pilih Sekarang"),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildHeader, _buildBudgetCard, _buildSafeCard sama seperti sebelumnya) ...
  // Paste ulang widget helper di bawah ini biar lengkap:

  Widget _buildHeader(DateTime now, double income, NumberFormat fmt) {
    return Column(
      children: [
        Text(
          DateFormat('MMMM yyyy', 'id_ID').format(now),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 5),
        const Text(
          "Gaji / Income Utama (G/M)",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          fmt.format(income),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required IconData icon,
    required Color color,
    required double current,
    required double target,
    required bool isExpenseLimit,
    required String desc,
  }) {
    final currency = NumberFormat.compact(locale: 'id_ID');
    double percent = (target == 0) ? 0 : (current / target).clamp(0.0, 1.0);

    Color progressColor;
    String status;

    if (isExpenseLimit) {
      if (percent < 0.7) {
        progressColor = Colors.greenAccent;
        status = "Aman";
      } else if (percent < 1.0) {
        progressColor = Colors.yellowAccent;
        status = "Hati-hati!";
      } else {
        progressColor = Colors.redAccent;
        status = "OVER!";
      }
    } else {
      if (percent < 0.5) {
        progressColor = Colors.redAccent;
        status = "Belum";
      } else if (percent < 1.0) {
        progressColor = Colors.yellowAccent;
        status = "Dikit Lagi";
      } else {
        progressColor = Colors.greenAccent;
        status = "Tercapai!";
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade800,
            color: progressColor,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${currency.format(current)} / ${currency.format(target)}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                status,
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafeCard({
    required String title,
    required double current,
    required double target,
    required NumberFormat currency,
  }) {
    bool isSafe = current >= target;
    Color statusColor = isSafe ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSafe
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                isSafe ? Icons.check_circle : Icons.warning_rounded,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Saldo Dompet Safe vs Target 30%",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Divider(color: Colors.white10, height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saldo Dompet:",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    currency.format(current),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Target:",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    currency.format(target),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            isSafe ? "Tabungan Aman 👍" : "Saldo di bawah target! 🚨",
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
