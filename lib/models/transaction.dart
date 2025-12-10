import 'package:hive/hive.dart';

// Ini mantra biar file ini bisa digenerate otomatis sama Hive
part 'transaction.g.dart';

// Kita kasih TypeId: 1 (Setiap model harus punya ID unik, jangan sama!)
@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String type; // 'income' atau 'expense'

  @HiveField(2)
  double amount; // Jumlah uang

  @HiveField(3)
  String category; // 'Gaji', 'Makan', dll

  @HiveField(4)
  String description; // Catatan tambahan

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String walletId; // ID Dompet yang dipakai

  @HiveField(7)
  bool isAllocated; // Khusus Gaji: Sudah dibagi-bagi belum?

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.walletId,
    this.isAllocated = false, // Defaultnya belum dialokasikan
  });
}
