import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String title;
  final String subtitle;
  final int price;
  final String iconName;
  final bool isAvailable;

  MenuItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.iconName,
    required this.isAvailable,
  });

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MenuItemModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      price: data['price'] ?? 0,
      iconName: data['icon_name'] ?? 'soup_kitchen_outlined',
      isAvailable: data['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'icon_name': iconName,
      'is_available': isAvailable,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final int subtotal;
  final int deliveryCharge;
  final int total;
  final String deliveryType;
  final String status;
  final DateTime timestamp;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.deliveryType,
    required this.status,
    required this.timestamp,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      subtotal: data['subtotal'] ?? 0,
      deliveryCharge: data['delivery_charge'] ?? 0,
      total: data['total'] ?? 0,
      deliveryType: data['delivery_type'] ?? 'Pickup',
      status: data['status'] ?? 'Order Received',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'items': items,
      'subtotal': subtotal,
      'delivery_charge': deliveryCharge,
      'total': total,
      'delivery_type': deliveryType,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
