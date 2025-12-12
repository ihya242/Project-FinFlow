import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';

// IMPORT HALAMAN-HALAMAN KITA
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'add_transaction_screen.dart';
import 'salary_control_screen.dart'; // <--- INI PENTING! (Kontrol Gaji)
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // DAFTAR HALAMAN (Harus urut sesuai Ikon di bawah)
  final List<Widget> _pages = [
    const HomeScreen(), // Index 0: Home
    const StatisticsScreen(), // Index 1: Analisa (Grafik)
    const SizedBox(), // Index 2: Kosong (Karena tombol tengah melayang)
    const SalaryControlScreen(), // Index 3: Kontrol Gaji (Ganti BudgetCards jadi ini)
    const ProfileScreen(), // Index 4: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack bikin halaman gak ngerestart pas pindah tab (PENTING!)
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
              // LOGIKA TOMBOL TENGAH (ADD)
              if (index == 2) {
                // 👮‍♂️ SATPAM CEK DOMPET
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
                  // BUKA HALAMAN ADD
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  );
                }
              } else {
                // PINDAH HALAMAN BIASA
                setState(() => _selectedIndex = index);
              }
            },
            items: [
              // 0. HOME
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),

              // 1. STATISTIK (Grafik)
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Stats',
              ),

              // 2. TOMBOL TENGAH (ADD)
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(12),
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

              // 3. KONTROL GAJI (Cards)
              const BottomNavigationBarItem(
                icon: Icon(Icons.credit_card_rounded),
                label: 'Cards', // Ini akan membuka SalaryControlScreen
              ),

              // 4. PROFILE
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
