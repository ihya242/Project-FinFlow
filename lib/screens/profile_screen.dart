import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';
import 'auth_screen.dart';
import 'manage_templates_screen.dart';
import 'welcome_screen.dart'; // Import Welcome Screen buat Logout/Reset

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userName = context.watch<MoneyProvider>().userName;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background Hitam Pekat
      appBar: AppBar(
        title: const Text("IDENTITY"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        // ✨ DEKORASI GOLD GRADIENT ✨
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.amber.withValues(alpha: 0.15), // Emas Transparan
                Colors.transparent,
              ],
            ),
          ),
        ),
        // ✨ TEKS GLOWING EMAS ✨
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto', // Atau font bawaan
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 2,
          color: Colors.white,
          shadows: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.8),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. AVATAR GLOWING ---
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF1E1E1E),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. KOTAK NAMA USER (KAPSUL) ---
            GestureDetector(
              onTap: _showEditNameDialog,
              child: Container(
                // Padding bikin kotaknya agak gendut & lega
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Latar Abu Gelap
                  borderRadius: BorderRadius.circular(30), // Sudut Membulat
                  border: Border.all(color: Colors.white10), // Garis tipis
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // Biar kotaknya gak melebar full
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20, // Ukuran Pas
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.edit, color: Colors.amber, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Julukan (Badge)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Master of Coin",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(width: 5),
                Text("👑", style: TextStyle(fontSize: 12)),
              ],
            ),

            const SizedBox(height: 40),

            // --- 3. MENU LIST ---
            _buildSectionTitle("Keamanan"),

            _buildMenuTile(
              icon: Icons.lock_reset_rounded,
              title: "Reset PIN & Keamanan",
              subtitle: "Hapus PIN lama dan buat baru",
              color: Colors.cyanAccent,
              onTap: () => _showResetPinDialog(),
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("Data & Penyimpanan"),

            _buildMenuTile(
              icon: Icons.list_alt_rounded,
              title: "Atur Template Transaksi",
              subtitle: "Tambah atau hapus template otomatis",
              color: Colors.greenAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageTemplatesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // FITUR EXPORT (Next Update)
            _buildMenuTile(
              icon: Icons.file_download_outlined,
              title: "Export ke Excel (CSV)",
              subtitle: "Backup datamu ke file",
              color: Colors.white,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur ini akan segera hadir, Sayang! 😉"),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            _buildMenuTile(
              icon: Icons.delete_forever_rounded,
              title: "Hapus Semua Data",
              subtitle: "Reset aplikasi ke awal (Hati-hati!)",
              color: Colors.redAccent,
              onTap: () => _showFactoryResetDialog(),
            ),

            // Footer
            const SizedBox(height: 40),
            const Divider(color: Colors.white10),
            const SizedBox(height: 20),
            const Text(
              "Money Tracker App v1.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Text(
              "Created with ❤️ by Ihya",
              style: TextStyle(color: Colors.white30, fontSize: 10),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 10, left: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color, // Wajib isi warna biar variatif
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
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade800,
        ),
        onTap: onTap,
      ),
    );
  }

  // --- LOGIC DIALOG ---

  void _showEditNameDialog() {
    String currentName = Provider.of<MoneyProvider>(
      context,
      listen: false,
    ).userName;
    TextEditingController controller = TextEditingController(text: currentName);

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
              borderSide: BorderSide(color: Colors.amber),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amberAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<MoneyProvider>(
                  context,
                  listen: false,
                ).updateUserName(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              "Simpan",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          "PIN dan data sidik jari akan dihapus. Kamu harus login ulang.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              var box = await Hive.openBox('settings');
              await box.delete('user_pin');

              if (!ctx.mounted) return;
              Navigator.pop(ctx);

              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            child: const Text(
              "Ya, Reset PIN",
              style: TextStyle(color: Colors.cyanAccent),
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
        // FIX: Bungkus Text dengan Expanded biar gak nabrak kanan
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Expanded(
              // <--- INI JUARA PENYELAMATNYA 🦸‍♂️
              child: Text(
                "Hapus SEMUA Data?",
                style: TextStyle(color: Colors.redAccent),
                overflow: TextOverflow.visible, // Biar teks turun ke bawah
              ),
            ),
          ],
        ),
        // FIX: Bungkus Content dengan Scroll biar aman di layar pendek
        content: const SingleChildScrollView(
          child: Text(
            "Dompet, transaksi, dan pengaturan akan dihapus PERMANEN.\nData tidak bisa dikembalikan. Yakin?",
            style: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await Provider.of<MoneyProvider>(
                context,
                listen: false,
              ).resetAllData();

              if (!ctx.mounted) return;
              Navigator.pop(ctx);

              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Aplikasi telah di-reset sepenuhnya."),
                ),
              );
            },
            child: const Text(
              "HAPUS SEMUANYA",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
