import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_format.dart'; // <--- IMPORT UTILS KITA 🛠️
import '../providers/money_provider.dart';
import 'add_wallet_screen.dart';
import 'wallet_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);
    // final currencyFormatter = ... (HAPUS YANG LAMA)

    return Scaffold(
      backgroundColor: const Color(
        0xFF121212,
      ), // Pastikan background hitam pekat
      // --- HEADER CYAN NEON (TETAP SAMA) ---
      appBar: AppBar(
        title: Text(
          "DOMPET ${provider.userName.toUpperCase()}",
        ), // Pakai uppercase biar gagah
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.cyanAccent,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Rekening",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddWalletScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    "Tambah Baru",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- 1. DAFTAR DOMPET ---
            provider.wallets.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = provider.wallets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.transparent,
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WalletDetailScreen(wallet: wallet),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            // 👇 DEKORASI INI DISAMAKAN DENGAN WALLET DETAIL
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2C2C2C),
                                  Colors.black,
                                ], // Hitam ke Abu Gelap
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.cyanAccent.withValues(alpha: 0.3),
                              ), // Border Cyan Tipis
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            // ------------------------------------------------
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.sim_card_rounded,
                                      color: Colors.cyanAccent,
                                      size: 32,
                                    ), // Icon Cyan
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        wallet.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.contactless_rounded,
                                      color: Colors.grey,
                                      size: 28,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  "Saldo Aktif",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),

                                // PAKAI UTILS
                                Text(
                                  AppFormat.currency(wallet.balance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),

            const Text(
              "Transaksi Terakhir",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),

            // --- 2. LIST TRANSAKSI ---
            provider.transactions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "Belum ada transaksi.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.transactions.length > 5
                        ? 5
                        : provider.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = provider.transactions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            tx.type == 'income'
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
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

                        // PAKAI UTILS TANGGAL 👇
                        subtitle: Text(
                          AppFormat.dateShort(tx.date),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        // PAKAI UTILS UANG 👇
                        trailing: Text(
                          AppFormat.currency(tx.amount),
                          style: TextStyle(
                            color: tx.type == 'income'
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          const Text(
            "Dompet Kosong",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          const Text(
            "Yuk tambah rekening pertamamu!",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWalletScreen()),
              );
            },
            child: const Text("Buat Dompet"),
          ),
        ],
      ),
    );
  }
}
