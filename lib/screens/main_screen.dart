import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'add_transaction_screen.dart'; // <--- JANGAN LUPA IMPORT INI
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';
import 'budget_cards_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const StatisticsScreen(),
    const Center(child: Text("Menu Tambah")), // Placeholder (gak akan tampil)
    const BudgetCardsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 2) {
                // 👮‍♂️ SATPAM CEK DOMPET
                // Kita intip provider (listen: false karena cuma mau cek sekali, gak perlu update UI)
                final provider = Provider.of<MoneyProvider>(
                  context,
                  listen: false,
                );

                if (provider.wallets.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Buat dompet dulu yuk sebelum catat transaksi! 🚫",
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  // LOGIKA BARU: BUKA HALAMAN TAMBAH TRANSAKSI 🚀
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  );
                }
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Stats',
              ),
              // Tombol Tengah Cantik
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(12), // Gedein dikit
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                label: 'Add',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.credit_card_rounded),
                label: 'Cards',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
