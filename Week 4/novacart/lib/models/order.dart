import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  Address({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
  });

  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pinCode;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pinCode: map['pinCode'] ?? '',
    );
  }
}

class OrderItem {
  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class OrderModel {
  OrderModel({
    required this.userId,
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.address,
    this.createdAt,
  });

  final String userId;
  final String orderId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final Address address;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'orderId': orderId,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'address': address.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Order data is null');
    }
    
    final itemsList = data['items'] as List<dynamic>? ?? [];

    return OrderModel(
      userId: data['userId'] ?? '',
      orderId: data['orderId'] ?? doc.id,
      items: itemsList.map((e) => OrderItem.fromMap(e as Map<String, dynamic>)).toList(),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      orderStatus: data['orderStatus'] ?? '',
      address: Address.fromMap(data['address'] as Map<String, dynamic>? ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
