import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model/cartmodel.dart';
import 'Homepage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentPage extends StatefulWidget {
  final List<CartModel> cartItems;
  final double totalPrice;
  final String selectedShippingMethod;
  final String selectedPaymentMethod;

  const PaymentPage({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
    required this.selectedPaymentMethod,
    required this.selectedShippingMethod,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String selectedShippingMethod;
  late String selectedPaymentMethod;
  late double shippingFee;

  @override
  void initState() {
    super.initState();
    selectedShippingMethod = widget.selectedShippingMethod;
    selectedPaymentMethod = widget.selectedPaymentMethod;
    shippingFee = _getShippingFee(selectedShippingMethod); 
  }

  // func checkการเลือกขนส่ง
  double _getShippingFee(String selectedShippingMethod) {
    if (selectedShippingMethod == 'Express Shipping') {
      return 50.0;
    } else {  
      return 25.0;
    }
  }

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  void checkout(BuildContext context) async {
    if (widget.cartItems.isEmpty) return;

    final userId = getCurrentUserId();
    if (userId == null) return;

    final orderCollection = FirebaseFirestore.instance.collection('orders');
    final orderDetails = widget.cartItems.map((item) => item.toMap()).toList();

    await orderCollection.add({
      'items': orderDetails,
      'totalPrice': widget.totalPrice + shippingFee, 
      'orderedAt': DateTime.now(),
      'userId': userId,
      'paymentMethod': selectedPaymentMethod,
      'shippingMethod': selectedShippingMethod,
      'status': "Currently shipping",
    });

    // เคลียร?ตะกร้า cart
    final cartCollection = FirebaseFirestore.instance.collection('cart');
    for (final item in widget.cartItems) {
      await cartCollection
          .where('productId', isEqualTo: item.productId)
          .where('selectedSize', isEqualTo: item.selectedSize)
          .where('selectedColor', isEqualTo: item.selectedColor)
          .where('userId', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final docId = querySnapshot.docs.first.id;
          cartCollection.doc(docId).delete();
        }
      });
    }

    Fluttertoast.showToast(
        msg: "Order successfully placed!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );

    // สั่งซื้อเสร็จไปหน้าหลัก
    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Homepage()), 
    (route) => false, 
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Payment", style: TextStyle(fontFamily: 'Outfit', fontSize: 25, fontWeight: FontWeight.w500)),
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Products in your cart",style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = widget.cartItems[index];
                  return Card(
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Image.network(
                        cartItem.productImage,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                        },
                      ),
                      title: Text(cartItem.productName, style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 17,
                            fontWeight: FontWeight.w400),),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Size: ${cartItem.selectedSize}  Color: ${cartItem.selectedColor}", style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w400
                          ),),
                          Text("Quantity: ${cartItem.quantity}   \$${cartItem.productPrice}", style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w400),)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10,),
              const Divider(  
                color: Colors.grey,  
                thickness: 1, 
                height: 20, 
              ),
            const SizedBox(height: 10),
            // รายละเอียดการซื่อ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shipping Method:", style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
                Text(selectedShippingMethod, style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Payment Method:", style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
                Text(selectedPaymentMethod, style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Delevery fee:", style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
                Text("\$${(shippingFee).toStringAsFixed(2)}", style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Price:", style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
                Text("\$${(widget.totalPrice + shippingFee).toStringAsFixed(2)}", style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18, 
                  fontWeight: FontWeight.w400)),
              ],
            ),
            const SizedBox(height: 32),
            // ปุ้่มซื้อ
            Center(
              child: ElevatedButton(
                onPressed: () => checkout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Proceed to Payment", style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16, 
                  color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
