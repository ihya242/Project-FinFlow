import 'package:hive/hive.dart';

part 'wallet.g.dart';

// Tadi Transaction typeId: 1, jadi Wallet kita kasih typeId: 2
// INGAT: typeId GABOLEH KEMBAR ya!
@HiveType(typeId: 2)
class Wallet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name; // Misal: "BCA", "Dompet Saku"

  @HiveField(2)
  double balance; // Saldo (Nggak 'final' karena bisa berubah nambah/kurang)

  Wallet({required this.id, required this.name, required this.balance});
}
