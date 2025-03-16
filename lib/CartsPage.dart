import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_project/PaymentPage.dart';
import 'package:shop_project/model/cartmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PaymentPage.dart';


class CartsPage extends StatefulWidget {
  const CartsPage({super.key});

  @override
  State<CartsPage> createState() => _CartsPageState();
}

class _CartsPageState extends State<CartsPage> {
  List<CartModel> cartItems = [];
  bool isLoading = true;

  // ส่งข้อมูลเลือกการขนส่งกับจ่าย
  String? selectedShippingMethod = "Standard Shipping";
  String? selectedPaymentMethod = "Credit Card";
  bool isShippingMethodVisible = false; 
  bool isPaymentMethodVisible = false;

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }


  void loadCartItems() async {
    setState(() {
      isLoading = true;
    });

    final userId = getCurrentUserId(); // ดึง User ID ของผู้ใช้ปัจจุบัน
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final cartCollection = FirebaseFirestore.instance.collection('cart');
    final snapshot = await cartCollection
        .where('userId', isEqualTo: userId) // กรองข้อมูลด้วย User ID
        .get();

    setState(() {
      cartItems = snapshot.docs
          .map((doc) => CartModel.fromMap(doc.data()))
          .toList();
      isLoading = false;
    });
  }

  void updateQuantity(int index, int change) async {
    final cartItem = cartItems[index];
    final newQuantity = cartItem.quantity + change;

    if (newQuantity < 1) return;

    final userId = getCurrentUserId(); // ดึง User ID ของผู้ใช้ปัจจุบัน
    if (userId == null) return;

    final cartCollection = FirebaseFirestore.instance.collection('cart');
    await cartCollection
        .where('productId', isEqualTo: cartItem.productId)
        .where('selectedSize', isEqualTo: cartItem.selectedSize)
        .where('selectedColor', isEqualTo: cartItem.selectedColor)
        .where('userId', isEqualTo: userId) // กรองข้อมูลด้วย User ID
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        cartCollection.doc(docId).update({'quantity': newQuantity});
      }
    });

    setState(() {
      cartItems[index].quantity = newQuantity;
    });
  }

  void removeItem(int index) async {
    final cartItem = cartItems[index];

    final userId = getCurrentUserId(); // ดึง User ID ของผู้ใช้ปัจจุบัน
    if (userId == null) return;

    final cartCollection = FirebaseFirestore.instance.collection('cart');
    await cartCollection
        .where('productId', isEqualTo: cartItem.productId)
        .where('selectedSize', isEqualTo: cartItem.selectedSize)
        .where('selectedColor', isEqualTo: cartItem.selectedColor)
        .where('userId', isEqualTo: userId) // กรองข้อมูลด้วย User ID
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        cartCollection.doc(docId).delete();
      }
    });

    setState(() {
      cartItems.removeAt(index);
    });
  }

  double get totalPrice {
    return cartItems.fold(
        0, (sum, item) => sum + (item.productPrice * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Shopping Cart", style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 25,
          fontWeight: FontWeight.w500

        ),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty",style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                  )))
              : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartItems[index];
                  return Card(
                    color: Colors.grey[100],
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8), 
                            child: Image.network(
                              cartItem.productImage,
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported,
                                    size: 80, color: Colors.grey);
                              },
                            ),
                          ),
                          const SizedBox(width: 12), 

                          // รายละเอียดสินค้า
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.productName,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text("Size: ${cartItem.selectedSize}     Color: ${cartItem.selectedColor}" 
                                ,style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                ),),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '\$${cartItem.productPrice}',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () => updateQuantity(index, -1),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color.fromARGB(255, 119, 118, 118),
                                            ),
                                            child: const Icon(Icons.remove, color: Colors.white, size: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 15, 
                                            fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () => updateQuantity(index, 1),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color.fromARGB(255, 119, 118, 118),
                                            ),
                                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // ปุ่มลบของตะกร้า
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromARGB(255, 0, 0, 0), 
                                        ),
                                        child: const Icon(Icons.delete, color: Colors.white, size: 15),
                                      ),
                                      onPressed: () => removeItem(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
            ),

            // popupเลือกการส่ง
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isShippingMethodVisible = !isShippingMethodVisible;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isShippingMethodVisible
                            ? "Select shipping method"
                            : "Select shipping method",
                        style: const TextStyle(
                            fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                      Icon(
                        isShippingMethodVisible
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        size: 24,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // แสดง
                Visibility(
                    visible: isShippingMethodVisible,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text("Standard shipping (3-5 days)", style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16)),
                            value: "Standard Shipping",
                            groupValue: selectedShippingMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedShippingMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text("Express Shipping (1-2 days)", style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16)),
                            value: "Express Shipping",
                            groupValue: selectedShippingMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedShippingMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // popupเลือกการจ่าย
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isPaymentMethodVisible = !isPaymentMethodVisible;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPaymentMethodVisible
                            ? "Select payment method"
                            : "Select payment method",
                        style: const TextStyle(
                            fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                      Icon(
                        isPaymentMethodVisible
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        size: 24,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // แสดง
                isPaymentMethodVisible
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text("Credit Card", style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16)),
                            value: "Credit Card",
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text("PayPal", style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16)),
                            value: "PayPal",
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text("Cash on delivery", style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16)),
                            value: "Cash on delivery",
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
                  // แสดงราคา
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total:",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18, 
                        fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "\$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18, 
                        fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed:() {
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ส่งข้อมูลราคา ส่งกับจ่าย
                      builder: (context) => PaymentPage(
                        cartItems: cartItems,
                        totalPrice: totalPrice,
                        selectedShippingMethod: selectedShippingMethod?? "",
                        selectedPaymentMethod: selectedPaymentMethod?? "",
                      ),
                    ),
                  );
                    },
                    // ปุ่มcheckout
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16, 
                        color: Colors.white,
                        ),
                    ),
                  ),
                ),
              ],
            ),
          )
    );
  }
}