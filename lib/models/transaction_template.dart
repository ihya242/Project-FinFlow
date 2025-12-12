import 'package:hive/hive.dart';

part 'transaction_template.g.dart';

@HiveType(typeId: 3) // ID unik baru
class TransactionTemplate extends HiveObject {
  @HiveField(0)
  final String title; // Nama Template (Contoh: "Gaji Bulanan")

  @HiveField(1)
  final String type; // 'income', 'expense', atau 'none' (kalau netral)

  TransactionTemplate({required this.title, required this.type});
}
