class CartItem {
  final int medicineId;
  final String medicineName;
  final String genericName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? description;

  CartItem({
    required this.medicineId,
    required this.medicineName,
    required this.genericName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    int? medicineId,
    String? medicineName,
    String? genericName,
    double? price,
    int? quantity,
    String? imageUrl,
    String? description,
  }) {
    return CartItem(
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      genericName: genericName ?? this.genericName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  double get totalPrice => price * quantity;
}

class Order {
  final int? id;
  final String shippingAddress;
  final String phoneNumber;
  final String paymentMethod;
  final String? notes;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    required this.shippingAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    this.notes,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'shipping_address': shippingAddress,
      'phone_number': phoneNumber,
      'payment_method': paymentMethod,
      'notes': notes ?? '',
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      shippingAddress: json['shipping_address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      notes: json['notes'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItem(
                medicineId: item['medicine_id'] ?? 0,
                medicineName: item['medicine_name'] ?? '',
                genericName: item['generic_name'] ?? '',
                price: (item['price'] ?? 0.0).toDouble(),
                quantity: item['quantity'] ?? 0,
                imageUrl: item['image_url'],
                description: item['description'],
              ))
          .toList() ?? [],
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}
