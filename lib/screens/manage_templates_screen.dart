import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/money_provider.dart';

class ManageTemplatesScreen extends StatelessWidget {
  const ManageTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context);
    final templates = provider.templates;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Hitam Pekat
      // --- HEADER GLOWING GREEN ---
      appBar: AppBar(
        title: const Text("ATUR TEMPLATE"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.greenAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // Dekorasi Gradient
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.greenAccent.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Teks Glowing
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 2,
          color: Colors.white,
          shadows: [
            BoxShadow(
              color: Colors.greenAccent.withValues(alpha: 0.8),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
      ),

      body: templates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.format_list_bulleted_add,
                    size: 80,
                    color: Colors.greenAccent.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Belum ada template",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Buat template untuk transaksi\nyang sering kamu lakukan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: templates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final temp = templates[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: temp.type == 'income'
                            ? Colors.greenAccent.withValues(alpha: 0.1)
                            : Colors.redAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: temp.type == 'income'
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        temp.type == 'income'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: temp.type == 'income'
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      temp.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        temp.type == 'income'
                            ? "Otomatis: PEMASUKAN"
                            : "Otomatis: PENGELUARAN",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => provider.deleteTemplate(temp),
                    ),
                  ),
                );
              },
            ),

      // --- FAB GLOWING ---
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black, // Kontras Hitam di atas Hijau
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedType = 'expense';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.greenAccent.withValues(alpha: 0.3),
              ),
            ),
            title: const Text(
              "TAMBAH TEMPLATE",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NAMA TEMPLATE",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Misal: Topup Game, Gaji",
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "JENIS TRANSAKSI",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildTypeButton(
                      "PENGELUARAN",
                      'expense',
                      selectedType,
                      Colors.redAccent,
                      () => setDialogState(() => selectedType = 'expense'),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeButton(
                      "PEMASUKAN",
                      'income',
                      selectedType,
                      Colors.greenAccent,
                      () => setDialogState(() => selectedType = 'income'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "BATAL",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    Provider.of<MoneyProvider>(
                      context,
                      listen: false,
                    ).addTemplate(nameController.text, selectedType);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  "SIMPAN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeButton(
    String label,
    String value,
    String groupValue,
    Color color,
    VoidCallback onTap,
  ) {
    bool isSelected = groupValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade800,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
