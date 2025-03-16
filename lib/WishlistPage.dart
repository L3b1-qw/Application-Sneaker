import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/WishlistModel.dart';
import 'model/productmodel.dart';  
import 'ProductDetailPage.dart'; 
import 'package:fluttertoast/fluttertoast.dart'; 

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<WishlistModel> wishlistItems = [];
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    loadWishlistItems();
  }

  // ดึงข้อมูล wishlist
  void loadWishlistItems() async {
    setState(() {
      isLoading = true;
    });

    final userId = getCurrentUserId();
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final wishlistCollection = _firestore.collection('wishlist');
    final snapshot = await wishlistCollection
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      wishlistItems = snapshot.docs.map((doc) {
        final data = doc.data();
        return WishlistModel.fromFirestore(data);
      }).toList();
      isLoading = false;
    });
  }

  // ฟังชันลบของ wishlist
  void removeItem(int productId) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return;

      final wishlistCollection = _firestore.collection('wishlist');

      final snapshot = await wishlistCollection
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          await wishlistCollection.doc(doc.id).delete();
        }
        Fluttertoast.showToast(
        msg: "item is remove from wishlist",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontAsset: 'Outfit',
        textColor: Colors.white,
        fontSize: 16.0
    );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item not found in wishlist')),
        );
      }

      loadWishlistItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึง userid ปัจจุบัน
    final userId = getCurrentUserId(); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Wishlist", style: TextStyle(
          fontSize: 25,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w500,
          color: Colors.black
        )),
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Center(
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userId != null
                  ? _firestore
                      .collection('wishlist')
                      .where('userId', isEqualTo: userId)
                      .snapshots()
                  : const Stream.empty(),
              builder: (context, snapshot) {
                if (isLoading || snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Wishlist Items",style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                  ),));
                }

                wishlistItems = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return WishlistModel.fromFirestore(data);
                }).toList();

                return ListView.builder(
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final wishlistItem = wishlistItems[index];
                    return GestureDetector(
                      onTap: () {
                        // กดไอเทมไปหน้า ProductDetailPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              product: Product.fromFirestore({
                                'productid': wishlistItem.productId,
                                'name': wishlistItem.productName,
                                'imageUrl': wishlistItem.productImage,
                                'price': wishlistItem.productPrice,
                                'brand': wishlistItem.brand, 
                                'description': wishlistItem.description,
                              }),
                            ),
                          ),
                        );
                      },
                      // card
                      child: Card(
                        color: Colors.grey[100],
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                wishlistItem.productImage,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported,
                                      size: 80, color: Colors.grey);
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wishlistItem.productName,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text("Price: \$${wishlistItem.productPrice}", style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 15,)),
                                  ],
                                ),
                              ),
                              // ปุ่มลบ
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(4), 
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 0, 0, 0), 
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 15), 
                                ),
                                onPressed: () => removeItem(wishlistItem.productId),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
