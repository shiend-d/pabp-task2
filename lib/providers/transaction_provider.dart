import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/cart_item_model.dart';
import '../services/transaction_service.dart';

enum TransactionState { idle, loading, error, loaded }

class TransactionProvider extends ChangeNotifier {
  TransactionState _state = TransactionState.idle;
  List<Transaction> _transactions = [];
  Transaction? _selectedTransaction;
  String _errorMessage = '';

  TransactionState get state => _state;
  List<Transaction> get transactions => _transactions;
  Transaction? get selectedTransaction => _selectedTransaction;
  String get errorMessage => _errorMessage;

  void selectTransaction(Transaction tx) {
    _selectedTransaction = tx;
    notifyListeners();
  }

  /// Create a new transaction (checkout)
  Future<bool> checkout({
    required String token,
    required List<CartItem> items,
    required double totalAmount,
    required double cashReceived,
    required double changeAmount,
  }) async {
    _state = TransactionState.loading;
    notifyListeners();

    try {
      await TransactionService.createTransaction(
        token: token,
        items: items,
        totalAmount: totalAmount,
        cashReceived: cashReceived,
        changeAmount: changeAmount,
      );
      _state = TransactionState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = TransactionState.error;
      notifyListeners();
      return false;
    }
  }

  /// Fetch today's transactions
  Future<void> fetchTransactions(String token) async {
    _state = TransactionState.loading;
    notifyListeners();

    try {
      _transactions = await TransactionService.getTransactions(token);
      if (_transactions.isNotEmpty && _selectedTransaction == null) {
        _selectedTransaction = _transactions.first;
      }
      _state = TransactionState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = TransactionState.error;
    }
    notifyListeners();
  }
}
