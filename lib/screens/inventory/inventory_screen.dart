import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medicine_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<MedicineProvider>().fetchMedicines(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMedicineForm({Medicine? medicine}) {
    final nameCtrl = TextEditingController(text: medicine?.name ?? '');
    final categoryCtrl = TextEditingController(text: medicine?.category ?? 'Obat Bebas');
    final priceCtrl = TextEditingController(text: medicine?.price.toInt().toString() ?? '');
    final stockCtrl = TextEditingController(text: medicine?.stock.toString() ?? '');
    final descCtrl = TextEditingController(text: medicine?.description ?? '');
    bool rxRequired = medicine?.requiresPrescription ?? false;
    final isEditing = medicine != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEditing ? 'Edit Obat' : 'Tambah Obat Baru',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Obat')),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: categoryCtrl.text.isNotEmpty ? categoryCtrl.text : 'Obat Bebas',
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: ['Obat Bebas', 'Obat Bebas Terbatas', 'Obat Keras', 'Antibiotik', 'Suplemen', 'Psikotropika']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => categoryCtrl.text = v ?? '',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (Rp)'))),
                      const SizedBox(width: 14),
                      Expanded(child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok'))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi (opsional)')),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Butuh Resep Dokter (Rx)'),
                    value: rxRequired,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => setDialogState(() => rxRequired = v),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final data = {
                            'name': nameCtrl.text,
                            'category': categoryCtrl.text,
                            'price': double.tryParse(priceCtrl.text) ?? 0,
                            'stock': int.tryParse(stockCtrl.text) ?? 0,
                            'requires_prescription': rxRequired,
                            'description': descCtrl.text,
                          };
                          final navigator = Navigator.of(ctx);
                          final token = context.read<AuthProvider>().token!;
                          final mp = context.read<MedicineProvider>();
                          bool ok;
                          if (isEditing) {
                            ok = await mp.updateMedicine(token, medicine.id, data);
                          } else {
                            ok = await mp.createMedicine(token, data);
                          }
                          if (ok) navigator.pop();
                        },
                        child: Text(isEditing ? 'Simpan' : 'Tambah'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok Obat'),
        actions: [
          SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari obat...', prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _showMedicineForm(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Obat'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, mp, _) {
          if (mp.state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (mp.state == ViewState.error) {
            return Center(child: Text(mp.errorMessage));
          }

          var meds = mp.medicines;
          if (_searchQuery.isNotEmpty) {
            meds = meds.where((m) => m.name.toLowerCase().contains(_searchQuery) || m.category.toLowerCase().contains(_searchQuery)).toList();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.primaryLight),
                columns: const [
                  DataColumn(label: Text('Nama Obat')),
                  DataColumn(label: Text('Kategori')),
                  DataColumn(label: Text('Harga'), numeric: true),
                  DataColumn(label: Text('Stok'), numeric: true),
                  DataColumn(label: Text('Resep')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: meds.map((m) {
                  return DataRow(cells: [
                    DataCell(Text(m.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(m.category)),
                    DataCell(Text('Rp ${m.price.toInt()}')),
                    DataCell(Text('${m.stock}', style: TextStyle(color: m.isLowStock ? AppColors.danger : AppColors.textPrimary, fontWeight: m.isLowStock ? FontWeight.w700 : FontWeight.normal))),
                    DataCell(m.requiresPrescription
                        ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.rxBadgeBackground, borderRadius: BorderRadius.circular(4)), child: const Text('Rx', style: TextStyle(color: AppColors.rxBadge, fontWeight: FontWeight.w700, fontSize: 12)))
                        : const Text('-')),
                    DataCell(Row(children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary), onPressed: () => _showMedicineForm(medicine: m)),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger), onPressed: () async {
                        final authProv = context.read<AuthProvider>();
                        final medProv = context.read<MedicineProvider>();
                        final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hapus Obat'), content: Text('Yakin hapus "${m.name}"?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))]));
                        if (confirm == true) {
                          final token = authProv.token!;
                          medProv.deleteMedicine(token, m.id);
                        }
                      }),
                    ])),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
