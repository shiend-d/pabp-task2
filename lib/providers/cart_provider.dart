import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};
  List<CartItem> get itemList => _items.values.toList();
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((_, cartItem) {
      total += cartItem.subtotal;
    });
    return total;
  }

  /// Add a medicine to the cart (or increment qty)
  void addItem(Medicine medicine) {
    if (medicine.isOutOfStock) return;

    if (_items.containsKey(medicine.id)) {
      final currentQty = _items[medicine.id]!.quantity;
      // Don't exceed available stock
      if (currentQty < medicine.stock) {
        _items[medicine.id]!.quantity += 1;
      }
    } else {
      _items[medicine.id] = CartItem(medicine: medicine);
    }
    notifyListeners();
  }

  /// Decrease quantity (remove if qty reaches 0)
  void decreaseItem(int medicineId) {
    if (!_items.containsKey(medicineId)) return;

    if (_items[medicineId]!.quantity > 1) {
      _items[medicineId]!.quantity -= 1;
    } else {
      _items.remove(medicineId);
    }
    notifyListeners();
  }

  /// Remove an item entirely
  void removeItem(int medicineId) {
    _items.remove(medicineId);
    notifyListeners();
  }

  /// Clear the entire cart (after checkout)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
