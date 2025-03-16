class Product {
  final int productid;
  final String name;
  final String imageUrl;
  final double price;
  final String brand; 
  final String description;

  Product({required this.productid,required this.name, required this.imageUrl, required this.price,required this.brand, required this.description});

  factory Product.fromFirestore(Map<String, dynamic> firestoreData) {
    return Product(
      productid: firestoreData['productid'] ?? 0,
      name: firestoreData['name'] ?? '',
      imageUrl: firestoreData['imageUrl'] ?? '',
      price: firestoreData['price']?.toDouble() ?? 0.0,
      brand: firestoreData['brand'] ?? '',
      description: firestoreData['description'] ?? '',
    );
  }
}