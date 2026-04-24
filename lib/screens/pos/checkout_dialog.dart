import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/medicine_provider.dart';

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  String _displayValue = '0';

  double get _totalAmount => context.read<CartProvider>().totalAmount;
  double get _cashReceived => double.tryParse(_displayValue) ?? 0;
  double get _changeAmount => _cashReceived - _totalAmount;

  void _onKeyPress(String value) {
    setState(() {
      if (_displayValue == '0') {
        _displayValue = value;
      } else {
        _displayValue += value;
      }
    });
  }

  void _onClear() => setState(() => _displayValue = '0');

  void _onBackspace() {
    setState(() {
      _displayValue = _displayValue.length > 1
          ? _displayValue.substring(0, _displayValue.length - 1)
          : '0';
    });
  }

  void _onQuickCash(int amount) {
    setState(() => _displayValue = amount.toString());
  }

  String _formatCurrency(double value) {
    final intValue = value.toInt();
    final text = intValue.abs().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;
      if (count % 3 == 0 && i > 0) buffer.write('.');
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return intValue < 0 ? '-Rp $formatted' : 'Rp $formatted';
  }

  Future<void> _handleConfirm() async {
    if (_changeAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang kurang!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final txProvider = context.read<TransactionProvider>();
    final token = context.read<AuthProvider>().token!;

    final success = await txProvider.checkout(
      token: token,
      items: cart.itemList,
      totalAmount: _totalAmount,
      cashReceived: _cashReceived,
      changeAmount: _changeAmount,
    );

    if (!mounted) return;

    if (success) {
      cart.clearCart();
      context.read<MedicineProvider>().fetchMedicines(token);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil!'), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(txProvider.errorMessage), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pembayaran', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text('Total Tagihan', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(_formatCurrency(_totalAmount), style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [10000, 20000, 50000, 100000].map((amt) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () => _onQuickCash(amt),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text(_formatCurrency(amt.toDouble()), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Text(_formatCurrency(_cashReceived), textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              _buildKeypad(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _changeAmount >= 0 ? AppColors.successLight : AppColors.dangerLight, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian', style: TextStyle(fontSize: 16)),
                    Text(_formatCurrency(_changeAmount), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: _changeAmount >= 0 ? AppColors.success : AppColors.danger)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Consumer<TransactionProvider>(
                  builder: (context, txProv, _) {
                    final isLoading = txProv.state == TransactionState.loading;
                    return ElevatedButton.icon(
                      onPressed: isLoading ? null : _handleConfirm,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle_outline),
                      label: Text(isLoading ? 'Memproses...' : 'Konfirmasi Pembayaran', style: const TextStyle(fontSize: 16)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [['1','2','3'],['4','5','6'],['7','8','9'],['C','0','⌫']];
    return Column(
      children: keys.map((row) => Row(
        children: row.map((key) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  if (key == 'C') {
                    _onClear();
                  } else if (key == '⌫') {
                    _onBackspace();
                  } else {
                    _onKeyPress(key);
                  }
                },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text(key, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        )).toList(),
      )).toList(),
    );
  }
}
