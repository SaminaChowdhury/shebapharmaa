import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class OrderService {
  static const String _baseUrl = ApiConfig.baseUrl;
  
  // Create a new order
  static Future<Map<String, dynamic>> createOrder({
    required String shippingAddress,
    required String phoneNumber,
    required String paymentMethod,
    String? notes,
    required List<Map<String, dynamic>> items,
    String? authToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/orders/create/');
      
      final body = {
        'shipping_address': shippingAddress,
        'phone_number': phoneNumber,
        'payment_method': paymentMethod,
        'notes': notes ?? '',
        'items': items,
      };

      final headers = authToken != null 
          ? ApiConfig.authHeaders(authToken)
          : ApiConfig.defaultHeaders;

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Order created successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create order: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating order: ${e.toString()}',
      };
    }
  }

  // Get order history
  static Future<Map<String, dynamic>> getOrderHistory({
    String? authToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/orders/orders/');
      
      final headers = authToken != null 
          ? ApiConfig.authHeaders(authToken)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load orders: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading orders: ${e.toString()}',
      };
    }
  }

  // Get order details by ID
  static Future<Map<String, dynamic>> getOrderDetails({
    required int orderId,
    String? authToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/orders/orders/$orderId/');
      
      final headers = authToken != null 
          ? ApiConfig.authHeaders(authToken)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load order details: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error loading order details: ${e.toString()}',
      };
    }
  }
}
