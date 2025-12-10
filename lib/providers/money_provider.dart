import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart'; // Buat bikin ID acak
import '../models/transaction.dart';
import '../models/wallet.dart';

class MoneyProvider extends ChangeNotifier {
  // 1. Akses ke Kardus Hive (Private biar aman)
  final Box<Transaction> _transactionBox = Hive.box<Transaction>(
    'transactions',
  );
  final Box<Wallet> _walletBox = Hive.box<Wallet>('wallets');

  // 2. Getter: Biar UI bisa minta datanya
  // Kita balik (reversed) biar transaksi terbaru muncul di paling atas
  List<Transaction> get transactions =>
      _transactionBox.values.toList().reversed.toList();

  List<Wallet> get wallets => _walletBox.values.toList();

  // 3. Hitung Total Saldo (Gabungan semua rekening)
  double get totalBalance {
    double total = 0;
    for (var wallet in _walletBox.values) {
      total += wallet.balance;
    }
    return total;
  }

  // --- FUNGSI-FUNGSI LOGIKA (ACTION) ---

  // Tambah Dompet Baru
  Future<void> addWallet(String name, double initialBalance) async {
    final newWallet = Wallet(
      id: const Uuid().v4(), // ID acak unik
      name: name,
      balance: initialBalance,
    );

    await _walletBox.add(newWallet);
    notifyListeners(); // "Oi UI! Ada dompet baru nih, update dong!"
  }

  // Tambah Transaksi
  Future<void> addTransaction({
    required String type, // 'income' atau 'expense'
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    required Wallet wallet, // Rekening mana yang dipake?
  }) async {
    // 1. Bikin objek transaksinya
    final newTx = Transaction(
      id: const Uuid().v4(),
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: date,
      walletId: wallet.id,
    );

    // 2. Simpan ke Hive
    await _transactionBox.add(newTx);

    // 3. Update Saldo Dompetnya
    // Kalau Income nambah, Kalau Expense ngurang
    if (type == 'income') {
      wallet.balance += amount;
    } else {
      wallet.balance -= amount;
    }
    // Simpan perubahan saldo dompet
    await wallet.save();

    notifyListeners(); // "Oi UI! Saldo berubah nih!"
  }

  // Hapus Transaksi (Optional, jaga-jaga kalau salah input)
  Future<void> deleteTransaction(Transaction tx) async {
    // Balikin dulu saldonya (Undo)
    final wallet = _walletBox.values.firstWhere((w) => w.id == tx.walletId);
    if (tx.type == 'income') {
      wallet.balance -= tx.amount;
    } else {
      wallet.balance += tx.amount;
    }
    await wallet.save();

    await tx.delete(); // Hapus dari Hive
    notifyListeners();
  }

  Future<void> editTransaction(Transaction oldTx, Transaction newTx) async {
    // 1. KEMBALIKAN Saldo Lama (Undo)
    // Kita cari dompet lama yang dipake transaksi ini
    final oldWallet = _walletBox.values.firstWhere(
      (w) => w.id == oldTx.walletId,
    );

    if (oldTx.type == 'income') {
      oldWallet.balance -= oldTx.amount; // Kalau tadinya masuk, kita tarik lagi
    } else {
      oldWallet.balance += oldTx.amount; // Kalau tadinya keluar, kita balikin
    }
    await oldWallet.save();

    // 2. UPDATE Data Transaksinya
    oldTx.amount = newTx.amount;
    oldTx.description = newTx.description;
    oldTx.type = newTx.type;
    oldTx.date = newTx.date;
    oldTx.walletId = newTx.walletId; // Siapa tau pindah dompet
    oldTx.category = newTx.category;
    await oldTx.save();

    // 3. TERAPKAN Saldo Baru (Redo)
    // Cari dompet baru (bisa jadi sama, bisa jadi beda kalau user ganti dompet)
    final newWallet = _walletBox.values.firstWhere(
      (w) => w.id == newTx.walletId,
    );

    if (newTx.type == 'income') {
      newWallet.balance += newTx.amount;
    } else {
      newWallet.balance -= newTx.amount;
    }
    await newWallet.save();

    notifyListeners(); // Kabarin UI buat refresh
  }

  Future<void> editWallet(
    Wallet wallet,
    String newName,
    double newBalance,
  ) async {
    wallet.name = newName;
    wallet.balance = newBalance;
    await wallet.save(); // Simpan perubahan ke Hive
    notifyListeners();
  }

  Future<void> deleteWallet(String walletId) async {
    // Hapus SEMUA transaksi yang numpang di dompet ini (Biar bersih)
    final txToDelete = _transactionBox.values
        .where((tx) => tx.walletId == walletId)
        .toList();
    for (var tx in txToDelete) {
      await tx.delete();
    }

    // Baru hapus dompetnya
    final wallet = _walletBox.values.firstWhere((w) => w.id == walletId);
    await wallet.delete();

    notifyListeners();
  }

  Future<void> resetAllData() async {
    // Hapus isi box
    await _transactionBox.clear();
    await _walletBox.clear();

    // Hapus setting juga
    var settingsBox = await Hive.openBox('settings');
    await settingsBox.clear();

    // Nah, karena ini di dalam class sendiri, BOLEH panggil ini:
    notifyListeners();
  }
}
