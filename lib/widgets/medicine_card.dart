import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/medicine_model.dart';
import '../providers/cart_provider.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({super.key, required this.medicine});

  String _formatPrice(double price) {
    final intVal = price.toInt().toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = intVal.length - 1; i >= 0; i--) {
      buf.write(intVal[i]);
      c++;
      if (c % 3 == 0 && i > 0) buf.write('.');
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = medicine.isOutOfStock;

    return Card(
      elevation: isOutOfStock ? 0 : 1,
      color: isOutOfStock ? AppColors.background : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOutOfStock ? AppColors.border : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          medicine.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (medicine.requiresPrescription) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.rxBadgeBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Rx',
                            style: TextStyle(
                              color: AppColors.rxBadge,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(medicine.price),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Stock + Add button
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Stok: ${medicine.stock}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: medicine.isLowStock
                        ? AppColors.danger
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isOutOfStock
                        ? null
                        : () {
                            context.read<CartProvider>().addItem(medicine);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
