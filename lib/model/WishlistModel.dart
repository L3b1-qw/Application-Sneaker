import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final int productId;
  final String productName;
  final double productPrice;
  final String productImage;
  final String? selectedSize; 
  final String? selectedColor; 
  final DateTime addedAt;
  final String brand;
  final String description;

  WishlistModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    this.selectedSize,
    this.selectedColor, 
    required this.addedAt,
    required this.brand,
    required this.description,
  });

  factory WishlistModel.fromFirestore(Map<String, dynamic> firestoreDoc) {
    return WishlistModel(
      productId: firestoreDoc['productId'],
      productName: firestoreDoc['productName'],
      productPrice: firestoreDoc['productPrice'].toDouble(),
      productImage: firestoreDoc['productImage'],
      selectedSize: firestoreDoc['selectedSize'], 
      selectedColor: firestoreDoc['selectedColor'],
      addedAt: (firestoreDoc['addedAt'] as Timestamp).toDate(),
      brand: firestoreDoc['brand'] ?? '',
      description: firestoreDoc['description'] ?? '',
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
      'brand': brand,
      'description': description,
    };
  }
}
