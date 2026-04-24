import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/transaction_model.dart';
import '../models/cart_item_model.dart';

class TransactionService {
  /// POST a new transaction with its items
  static Future<Transaction> createTransaction({
    required String token,
    required List<CartItem> items,
    required double totalAmount,
    required double cashReceived,
    required double changeAmount,
  }) async {
    // 1. Create the transaction header
    final txResponse = await http.post(
      Uri.parse(ApiConstants.transactionsUrl),
      headers: ApiConstants.authHeadersWithPrefer(token),
      body: jsonEncode({
        'total_amount': totalAmount,
        'cash_received': cashReceived,
        'change_amount': changeAmount,
        'items_count': items.length,
      }),
    );

    if (txResponse.statusCode != 201) {
      throw Exception(
          'Gagal menyimpan transaksi (${txResponse.statusCode})');
    }

    final List<dynamic> txResult =
        jsonDecode(txResponse.body) as List<dynamic>;
    final tx =
        Transaction.fromJson(txResult.first as Map<String, dynamic>);

    // 2. Create all transaction items
    final itemsData = items
        .map((item) => {
              'transaction_id': tx.id,
              'medicine_id': item.medicine.id,
              'medicine_name': item.medicine.name,
              'quantity': item.quantity,
              'unit_price': item.medicine.price,
              'subtotal': item.subtotal,
            })
        .toList();

    final itemsResponse = await http.post(
      Uri.parse(ApiConstants.transactionItemsUrl),
      headers: ApiConstants.authHeadersWithPrefer(token),
      body: jsonEncode(itemsData),
    );

    if (itemsResponse.statusCode != 201) {
      throw Exception('Gagal menyimpan item transaksi');
    }

    return tx;
  }

  /// GET all transactions with their items (today only)
  static Future<List<Transaction>> getTransactions(String token) async {
    // Get today's date in ISO format
    final today = DateTime.now().toUtc().toIso8601String().split('T')[0];
    final url =
        '${ApiConstants.transactionsUrl}?created_at=gte.${today}T00:00:00&order=created_at.desc&select=*,transaction_items(*)';

    final response = await http.get(
      Uri.parse(url),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          'Gagal memuat riwayat transaksi (${response.statusCode})');
    }
  }
}
