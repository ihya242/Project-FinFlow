import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/transaction_template.dart';

class MoneyProvider extends ChangeNotifier {
  late Box<Transaction> _transactionBox;
  late Box<Wallet> _walletBox;
  late Box<TransactionTemplate> _templateBox;

  List<Transaction> _transactions = [];
  List<Wallet> _wallets = [];
  List<TransactionTemplate> _templates = [];

  List<Transaction> get transactions => _transactions;
  List<Wallet> get wallets => _wallets;
  List<TransactionTemplate> get templates => _templates;

  String _userName = "User";
  String get userName => _userName;

  MoneyProvider() {
    _init();
  }

  void _init() async {
    _transactionBox = Hive.box<Transaction>('transactions');
    _walletBox = Hive.box<Wallet>('wallets');
    _templateBox = Hive.box<TransactionTemplate>('templates');
    var settingsBox = await Hive.openBox('settings');
    _userName = settingsBox.get('user_name', defaultValue: 'FinFlow User');

    if (_templateBox.isEmpty) {
      _seedDefaultTemplates();
    }

    _loadData();
    _loadTemplates();
  }

  void _loadData() {
    _transactions = _transactionBox.values.toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _wallets = _walletBox.values.toList();
    notifyListeners();
  }

  void _seedDefaultTemplates() {
    final defaults = [
      TransactionTemplate(title: "Gaji per Month (G/M)", type: "income"),
      TransactionTemplate(title: "Needs Monthly", type: "expense"),
      TransactionTemplate(title: "Invest Gold", type: "expense"),
      TransactionTemplate(title: "Safe Cash", type: "expense"),
      TransactionTemplate(title: "Makan & Minum", type: "expense"),
      TransactionTemplate(title: "Transport", type: "expense"),
    ];
    _templateBox.addAll(defaults);
  }

  void _loadTemplates() {
    _templates = _templateBox.values.toList();
    notifyListeners();
  }

  // --- WALLET CRUD ---
  Future<void> addWallet(String name, double balance) async {
    final newWallet = Wallet(
      id: DateTime.now().toString(),
      name: name,
      balance: balance,
    );
    await _walletBox.add(newWallet);
    _loadData();
  }

  Future<void> editWallet(
    Wallet wallet,
    String newName,
    double newBalance,
  ) async {
    wallet.name = newName;
    wallet.balance = newBalance;
    await wallet.save();
    notifyListeners();
  }

  Future<void> deleteWallet(String walletId) async {
    final txToDelete = _transactionBox.values
        .where((tx) => tx.walletId == walletId)
        .toList();
    for (var tx in txToDelete) {
      await tx.delete();
    }

    final wallet = _walletBox.values.firstWhere((w) => w.id == walletId);
    await wallet.delete();
    _loadData();
  }

  // --- TRANSACTION CRUD ---
  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    required Wallet wallet,
  }) async {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: date,
      walletId: wallet.id,
    );

    await _transactionBox.add(newTx);

    // Update Saldo
    if (type == 'income') {
      wallet.balance += amount;
    } else {
      wallet.balance -= amount;
    }
    await wallet.save();

    _loadData();
  }

  // --- FUNGSI YANG HILANG (SUDAH DITAMBAHKAN) 👇 ---

  Future<void> deleteTransaction(Transaction tx) async {
    // 1. Kembalikan Saldo Dompet dulu
    // Cari dompet aslinya
    try {
      final wallet = _walletBox.values.firstWhere((w) => w.id == tx.walletId);
      if (tx.type == 'income') {
        wallet.balance -= tx.amount; // Kalau tadinya income, kita kurangi balik
      } else {
        wallet.balance +=
            tx.amount; // Kalau tadinya expense, kita balikin duitnya
      }
      await wallet.save();
    } catch (e) {
      // Kalau dompet udah kehapus duluan, yaudah abaikan
    }

    // 2. Hapus Transaksi
    await tx.delete();
    _loadData();
  }

  Future<void> editTransaction(
    Transaction tx, {
    required String newType, // 'income' atau 'expense'
    required double newAmount,
    required String newDescription,
    required DateTime newDate,
  }) async {
    // 1. Cari Dompet yang Terlibat
    final wallet = _walletBox.values.firstWhere((w) => w.id == tx.walletId);

    // 2. REVERT (Batalkan) Efek Transaksi Lama ke Saldo
    if (tx.type == 'income') {
      wallet.balance -= tx.amount; // Tarik balik uang masuk
    } else {
      wallet.balance += tx.amount; // Balikin uang keluar
    }

    // 3. UPDATE Data Transaksi
    tx.type = newType;
    tx.amount = newAmount;
    tx.description = newDescription;
    tx.date = newDate;
    // Update Kategori teksnya juga biar rapi
    tx.category = newType == 'income' ? 'Pemasukan' : 'Pengeluaran';

    // 4. APPLY (Terapkan) Efek Transaksi Baru ke Saldo
    if (newType == 'income') {
      wallet.balance += newAmount;
    } else {
      wallet.balance -= newAmount;
    }

    // 5. Simpan Semuanya
    await tx.save();
    await wallet.save();

    _loadData();
    notifyListeners();
  }
  // ------------------------------------------------

  // --- TEMPLATE CRUD ---
  Future<void> addTemplate(String title, String type) async {
    final newTemp = TransactionTemplate(title: title, type: type);
    await _templateBox.add(newTemp);
    _loadTemplates();
  }

  Future<void> deleteTemplate(TransactionTemplate template) async {
    await template.delete();
    _loadTemplates();
  }

  Future<void> resetAllData() async {
    await _transactionBox.clear();
    await _walletBox.clear();
    await _templateBox.clear();
    var settingsBox = await Hive.openBox('settings');
    await settingsBox.clear();
    _seedDefaultTemplates();
    _loadData();
    _loadTemplates();
    notifyListeners();
  }

  Future<void> updateUserName(String newName) async {
    var settingsBox = await Hive.openBox('settings');
    await settingsBox.put('user_name', newName); // Simpan ke Hive
    _userName = newName; // Update di Memori
    notifyListeners(); // Kabari Home & Profile biar berubah!
  }
}
