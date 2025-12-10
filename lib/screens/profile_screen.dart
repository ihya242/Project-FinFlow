import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Ihya-kun";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    var box = await Hive.openBox('settings');
    // Cek apakah Halaman ini (State) masih ada?
    if (!mounted) return;
    setState(() {
      _userName = box.get('user_name', defaultValue: 'Ihya-kun');
    });
  }

  void _updateName(String newName) async {
    var box = await Hive.openBox('settings');
    await box.put('user_name', newName);

    // Cek apakah Halaman ini (State) masih ada?
    if (!mounted) return;
    setState(() => _userName = newName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. HEADER PROFIL ---
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF2C2C2C),
                child: Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Nama
            GestureDetector(
              onTap: _showEditNameDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Master of Coin 👑",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // --- 2. MENU PENGATURAN ---
            _buildSectionTitle("Keamanan"),
            _buildMenuTile(
              icon: Icons.lock_reset_rounded,
              title: "Reset PIN & Keamanan",
              subtitle: "Hapus PIN lama dan buat baru",
              onTap: () => _showResetPinDialog(),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Data & Penyimpanan"),
            _buildMenuTile(
              icon: Icons.delete_forever_rounded,
              title: "Hapus Semua Data",
              subtitle: "Reset aplikasi ke awal (Hati-hati!)",
              color: Colors.redAccent,
              onTap: () => _showFactoryResetDialog(),
            ),

            // ... Footer dll ...
            const SizedBox(height: 40),
            const Divider(color: Colors.white10),
            const SizedBox(height: 20),
            const Text(
              "Money Tracker App v1.0",
              style: TextStyle(color: Colors.grey),
            ),
            const Text(
              "Created with ❤️ by Ihya",
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper (Sama seperti sebelumnya)
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 10, left: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // --- LOGIKA PERBAIKAN ---

  void _showEditNameDialog() {
    TextEditingController controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Ganti Nama Panggilan",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nama barumu...",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _updateName(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showResetPinDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Reset PIN?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "PIN dan data sidik jari akan dihapus. Kamu harus membuat PIN baru saat login berikutnya.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              var box = await Hive.openBox('settings');
              await box.delete('user_pin');

              // 1. CEK KONTEK DIALOG DULU SEBELUM POP
              if (!ctx.mounted) return;
              Navigator.pop(ctx);

              // 2. CEK KONTEK HALAMAN (State) SEBELUM PINDAH LAYAR
              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            child: const Text(
              "Ya, Reset PIN",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _showFactoryResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Hapus SEMUA Data?",
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          "⚠️ PERINGATAN KERAS:\nSemua dompet, transaksi, dan pengaturan akan dihapus PERMANEN.\n\nData tidak bisa dikembalikan. Yakin?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              // Reset di Provider
              // Note: Pastikan di MoneyProvider fungsinya tidak pakai context, tapi notifyListeners
              await Provider.of<MoneyProvider>(
                context,
                listen: false,
              ).resetAllData();

              // 1. CEK KONTEK DIALOG (ctx)
              if (!ctx.mounted) return;
              Navigator.pop(ctx);

              // 2. CEK KONTEK HALAMAN (mounted)
              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Aplikasi telah di-reset sepenuhnya."),
                ),
              );
            },
            child: const Text("HAPUS SEMUANYA"),
          ),
        ],
      ),
    );
  }
}
