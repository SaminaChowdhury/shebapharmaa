import 'package:flutter/foundation.dart';
import 'models.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.insert(0, order); // Add new orders at the top
    notifyListeners();
  }

  void updateOrderStatus(int orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final updatedOrder = Order(
        id: _orders[index].id,
        shippingAddress: _orders[index].shippingAddress,
        phoneNumber: _orders[index].phoneNumber,
        paymentMethod: _orders[index].paymentMethod,
        notes: _orders[index].notes,
        items: _orders[index].items,
        totalAmount: _orders[index].totalAmount,
        status: newStatus,
        createdAt: _orders[index].createdAt,
        updatedAt: DateTime.now(),
      );
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
