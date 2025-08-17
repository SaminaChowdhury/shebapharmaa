import 'package:flutter/foundation.dart';
import 'models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.length;
  
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  
  bool get isEmpty => _items.isEmpty;
  
  // Add item to cart
  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((element) => element.medicineId == item.medicineId);
    
    if (existingIndex >= 0) {
      // Update quantity if item already exists
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      _items.add(item);
    }
    
    notifyListeners();
  }
  
  // Remove item from cart
  void removeItem(int medicineId) {
    _items.removeWhere((item) => item.medicineId == medicineId);
    notifyListeners();
  }
  
  // Update item quantity
  void updateQuantity(int medicineId, int quantity) {
    if (quantity <= 0) {
      removeItem(medicineId);
      return;
    }
    
    final index = _items.indexWhere((item) => item.medicineId == medicineId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }
  
  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  
  // Get item by medicine ID
  CartItem? getItem(int medicineId) {
    try {
      return _items.firstWhere((item) => item.medicineId == medicineId);
    } catch (e) {
      return null;
    }
  }
  
  // Check if item exists in cart
  bool hasItem(int medicineId) {
    return _items.any((item) => item.medicineId == medicineId);
  }
  
  // Get item quantity
  int getItemQuantity(int medicineId) {
    final item = getItem(medicineId);
    return item?.quantity ?? 0;
  }
}
