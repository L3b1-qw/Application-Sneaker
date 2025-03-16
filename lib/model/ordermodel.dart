import 'package:cloud_firestore/cloud_firestore.dart';
import 'cartmodel.dart';

class OrderModel {
  final String orderId;
  final List<CartModel> items;
  final double totalPrice;
  final DateTime orderedAt;
  final String status; 
  final String paymentMethod; 
  final String shippingMethod;


  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalPrice,
    required this.orderedAt,
    required this.status, 
    required this.paymentMethod,
    required this.shippingMethod
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      orderId: id,
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => CartModel.fromMap(item))
          .toList(),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      orderedAt: (data['orderedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending', 
      paymentMethod: data['paymentMethod'] ?? "ไม่ระบุ",
      shippingMethod: data['shippingMethod'] ?? "ไม่ระบุขนส่ง",
    );
  }
}