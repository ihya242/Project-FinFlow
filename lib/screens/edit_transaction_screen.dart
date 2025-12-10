import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../providers/money_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction; // Data lama yang mau diedit

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late String _type;
  late Wallet _selectedWallet;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Isi formulir dengan data lama
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(0),
    );
    _descController = TextEditingController(
      text: widget.transaction.description,
    );
    _type = widget.transaction.type;
    _selectedDate = widget.transaction.date;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoneyProvider>(context, listen: false);
    final wallets = context.read<MoneyProvider>().wallets;

    // Cari objek wallet yang sesuai ID lama
    try {
      _selectedWallet = wallets.firstWhere(
        (w) => w.id == widget.transaction.walletId,
      );
    } catch (e) {
      _selectedWallet = wallets.first; // Fallback kalau error
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Transaksi ✏️")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. JENIS TRANSAKSI
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Pengeluaran'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Pemasukan'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _type = newSelection.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return _type == 'income'
                        ? Colors.green[100]
                        : Colors.red[100];
                  }
                  return null;
                }),
              ),
            ),

            const SizedBox(height: 16),

            // 2. DOMPET
            InputDecorator(
              decoration: const InputDecoration(
                labelText: "Dompet",
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Wallet>(
                  value: _selectedWallet,
                  isExpanded: true,
                  items: wallets
                      .map(
                        (w) => DropdownMenuItem(value: w, child: Text(w.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedWallet = val!),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. JUMLAH & KETERANGAN
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah (Rp)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Keterangan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL UPDATE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  // Bikin objek dummy buat nampung data baru
                  final newTxData = Transaction(
                    id: widget.transaction.id, // ID Tetap sama
                    type: _type,
                    amount: double.tryParse(_amountController.text) ?? 0,
                    category:
                        widget.transaction.category, // Kategori ikut lama dulu
                    description: _descController.text,
                    date: _selectedDate,
                    walletId: _selectedWallet.id,
                  );

                  // Panggil Provider Edit
                  provider.editTransaction(widget.transaction, newTxData);

                  Navigator.pop(context); // Tutup Screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data berhasil diperbarui! ✅"),
                    ),
                  );
                },
                child: const Text("UPDATE PERUBAHAN"),
              ),
            ),

            const SizedBox(height: 10),

            // TOMBOL HAPUS (Merah)
            TextButton.icon(
              onPressed: () {
                // Konfirmasi dulu biar gak kepencet
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Hapus Transaksi?"),
                    content: const Text(
                      "Saldo dompet akan dikembalikan seperti semula.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.deleteTransaction(widget.transaction);
                          Navigator.pop(ctx); // Tutup Dialog
                          Navigator.pop(context); // Tutup Screen Edit
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Transaksi dihapus 🗑️"),
                            ),
                          );
                        },
                        child: const Text(
                          "HAPUS",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                "Hapus Transaksi Ini",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
