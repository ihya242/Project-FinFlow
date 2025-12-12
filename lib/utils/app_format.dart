import 'package:intl/intl.dart';

class AppFormat {
  // 1. Format Rupiah (Contoh: Rp 50.000)
  // Cara pakai: AppFormat.currency(50000)
  static String currency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // 2. Format Rupiah Ringkas (Contoh: 1.5jt, 500rb) - Buat Grafik
  // Cara pakai: AppFormat.compactCurrency(1500000)
  static String compactCurrency(double amount) {
    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: '', // Tanpa Rp biar hemat tempat di grafik
    ).format(amount);
  }

  // 3. Format Tanggal Lengkap (Contoh: Jumat, 12 Desember 2025)
  static String dateFull(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  // 4. Format Tanggal Singkat (Contoh: 12 Des 2025)
  static String dateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // 5. Format Bulan Tahun (Contoh: Desember 2025)
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }
}
