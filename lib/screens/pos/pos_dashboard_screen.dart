import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medicine_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';

import '../../widgets/medicine_card.dart';
import '../../widgets/cart_panel.dart';
import '../inventory/inventory_screen.dart';
import '../history/history_screen.dart';
import '../auth/login_screen.dart';

class PosDashboardScreen extends StatefulWidget {
  const PosDashboardScreen({super.key});

  @override
  State<PosDashboardScreen> createState() => _PosDashboardScreenState();
}

class _PosDashboardScreenState extends State<PosDashboardScreen> {
  final int _selectedNavIndex = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMedicines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMedicines() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<MedicineProvider>().fetchMedicines(token);
    }
  }

  void _onNavChanged(int index) {
    if (index == _selectedNavIndex) return;

    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const InventoryScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HistoryScreen()),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedNavIndex,
            onDestinationSelected: _onNavChanged,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                Icons.local_pharmacy_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    color: AppColors.textSecondary,
                    tooltip: 'Logout',
                    onPressed: _handleLogout,
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.point_of_sale_outlined),
                selectedIcon: Icon(Icons.point_of_sale),
                label: Text('Kasir'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Stok'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Riwayat'),
              ),
            ],
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // Medicine catalog (center)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama obat atau kategori...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                context.read<MedicineProvider>().search('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      context.read<MedicineProvider>().search(value);
                      setState(() {});
                    },
                  ),
                ),

                // Medicine grid
                Expanded(
                  child: Consumer<MedicineProvider>(
                    builder: (context, medicineProv, _) {
                      // THREE-STATE UI
                      switch (medicineProv.state) {
                        case ViewState.loading:
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Memuat daftar obat...'),
                              ],
                            ),
                          );
                        case ViewState.error:
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 64, color: AppColors.danger),
                                const SizedBox(height: 16),
                                Text(
                                  medicineProv.errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadMedicines,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          );
                        case ViewState.loaded:
                          if (medicineProv.medicines.isEmpty) {
                            return const Center(
                              child: Text('Tidak ada obat ditemukan'),
                            );
                          }
                          return _buildMedicineGrid(medicineProv.medicines);
                        default:
                          return const SizedBox();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // Cart panel (right)
          const Expanded(
            flex: 4,
            child: CartPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineGrid(List<Medicine> medicines) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
        ),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          return MedicineCard(medicine: medicines[index]);
        },
      ),
    );
  }
}
