import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/order_provider.dart';
import '../../core/order_service.dart';
import '../../core/models.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String? authToken; // Pass token after login

  const OrderHistoryScreen({Key? key, this.authToken}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<OrderProvider>(context, listen: false);

    // clear any old orders first
    provider.clearOrders();

    final response = await OrderService.getOrderHistory(
      authToken: widget.authToken,
    );

    if (response['success'] == true) {
      try {
        List<Order> orders = (response['data'] as List)
            .map((json) => Order.fromJson(json))
            .toList();

        for (var order in orders) {
          provider.addOrder(order);
        }

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error parsing orders: $e";
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : orderProvider.orders.isEmpty
          ? const Center(child: Text("No orders found"))
          : RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.builder(
          itemCount: orderProvider.orders.length,
          itemBuilder: (context, index) {
            final order = orderProvider.orders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text("Order #${order.id}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status: ${order.status}"),
                    Text("Total: \$${order.totalAmount}"),
                    Text("Date: ${order.createdAt}"),
                  ],
                ),
                onTap: () {
                  // TODO: navigate to details screen if needed
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
