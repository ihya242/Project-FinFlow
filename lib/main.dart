import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_tracker/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
// Import screen yang dibutuhkan saja
import 'screens/auth_screen.dart';
import 'models/transaction.dart';
import 'models/wallet.dart';
import 'models/transaction_template.dart';
import 'providers/money_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(TransactionTemplateAdapter());

  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Wallet>('wallets');
  await Hive.openBox<TransactionTemplate>('templates');
  await Hive.openBox('settings'); // Box buat simpan PIN

  await initializeDateFormatting('id_ID', null);

  var settingsBox = await Hive.openBox('settings');

  bool isNewUser = settingsBox.get('user_name') == null;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MoneyProvider())],
      // Kirim status user ke MyApp
      child: MyApp(isNewUser: isNewUser),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isNewUser;
  const MyApp({super.key, required this.isNewUser});

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

        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2C2C2C),
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Colors.tealAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
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
      home: isNewUser ? const WelcomeScreen() : const AuthScreen(),
    );
  }
}
