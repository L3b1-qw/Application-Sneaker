import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final int productId;
  final String productName;
  final double productPrice;
  final String productImage;
  final String selectedSize;
  final String selectedColor;
  final DateTime addedAt;
  int quantity;

  CartModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.selectedSize,
    required this.selectedColor,
    required this.addedAt,
    this.quantity = 1,

  });

  factory CartModel.fromMap(Map<String, dynamic> firestoreDoc) {
    return CartModel(
      productId: firestoreDoc['productId'],
      productName: firestoreDoc['productName'],
      productPrice: firestoreDoc['productPrice'].toDouble(),
      productImage: firestoreDoc['productImage'],
      selectedSize: firestoreDoc['selectedSize'],
      selectedColor: firestoreDoc['selectedColor'],
      addedAt: (firestoreDoc['addedAt'] as Timestamp).toDate(),
      quantity: firestoreDoc['quantity'] ?? 1, 

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'addedAt': addedAt,
      'quantity': quantity,

    };
  }
}
