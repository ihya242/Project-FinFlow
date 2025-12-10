import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
// Import screen yang dibutuhkan saja
import 'screens/auth_screen.dart';
import 'models/transaction.dart';
import 'models/wallet.dart';
import 'providers/money_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(WalletAdapter());
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Wallet>('wallets');
  await Hive.openBox('settings'); // Box buat simpan PIN

  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MoneyProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinFlow',

      // --- TEMA GELAP MODERN (FIXED) ---
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),

        // Ganti ColorScheme di sini
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4081),
          secondary: Color(0xFF7C4DFF),
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),

        // Style Text
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: const Color(0xFF1E1E1E),
          elevation: 0,
        ),

        // Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: const Color(0xFFFF4081),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      // --- AKHIR TEMA ---

      // Masuk ke AuthScreen dulu (Login)
      home: const AuthScreen(),
    );
  }
}
