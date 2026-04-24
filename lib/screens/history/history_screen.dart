import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<TransactionProvider>().fetchTransactions(token);
      }
    });
  }

  String _formatCurrency(double value) {
    final f = NumberFormat('#,###', 'id_ID');
    return 'Rp ${f.format(value.toInt())}';
  }

  String _formatTime(DateTime dt) {
    return DateFormat('HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi Hari Ini')),
      body: Consumer<TransactionProvider>(
        builder: (context, txProv, _) {
          if (txProv.state == TransactionState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (txProv.state == TransactionState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text(txProv.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final token = context.read<AuthProvider>().token;
                      if (token != null) txProv.fetchTransactions(token);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (txProv.transactions.isEmpty) {
            return const Center(child: Text('Belum ada transaksi hari ini'));
          }

          return Row(
            children: [
              // Left: transaction list
              SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('${txProv.transactions.length} Transaksi',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: txProv.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = txProv.transactions[index];
                          final isSelected = txProv.selectedTransaction?.id == tx.id;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: AppColors.primaryLight,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Icon(Icons.receipt, color: AppColors.primary, size: 20),
                            ),
                            title: Text('Transaksi #${tx.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${_formatTime(tx.createdAt)} · ${tx.itemsCount} item'),
                            trailing: Text(_formatCurrency(tx.totalAmount),
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.success)),
                            onTap: () => txProv.selectTransaction(tx),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              // Right: receipt detail
              Expanded(
                child: txProv.selectedTransaction == null
                    ? const Center(child: Text('Pilih transaksi untuk melihat detail'))
                    : _buildReceiptDetail(txProv.selectedTransaction!),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReceiptDetail(Transaction tx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.local_pharmacy_rounded, size: 40, color: AppColors.primary),
              const SizedBox(height: 8),
              Text('ApoCash', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text('Struk #${tx.id}', style: const TextStyle(color: AppColors.textSecondary)),
              Text(DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt.toLocal()), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),
              const Divider(),
              if (tx.items != null && tx.items!.isNotEmpty)
                ...tx.items!.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('${item.quantity}x @ ${_formatCurrency(item.unitPrice)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ])),
                          Text(_formatCurrency(item.subtotal), style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ))
              else
                const Padding(padding: EdgeInsets.all(20), child: Text('Detail item tidak tersedia')),
              const Divider(),
              const SizedBox(height: 8),
              _receiptRow('Total', _formatCurrency(tx.totalAmount), bold: true),
              const SizedBox(height: 4),
              _receiptRow('Tunai', _formatCurrency(tx.cashReceived)),
              _receiptRow('Kembalian', _formatCurrency(tx.changeAmount)),
              const SizedBox(height: 16),
              const Text('Terima kasih!', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
        Text(value, style: GoogleFonts.inter(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}
