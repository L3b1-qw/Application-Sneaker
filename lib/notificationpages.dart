import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_project/orderdetailpage.dart';
import 'model/ordermodel.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<OrderModel> orders = [];

  // ดึง User ID ของผู้ใช้ปัจจุบัน
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // โหลดข้อมูลการสั่งซื้อ
  void loadOrders() async {
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

    final ordersCollection = _firestore.collection('orders');
    final snapshot = await ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderedAt', descending: true)
        .get();

    setState(() {
      orders = snapshot.docs
    .map((doc) => OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
    .toList();
      isLoading = false;
    });
  }

  // ฟังชันเคลียร์รายการจาก UI
  void clearOrders() {
    setState(() {
      orders.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text("Order Notifications", style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: clearOrders,
            tooltip: "Clear Orders",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No orders found",style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                  )))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      color: Colors.grey[100],
                      margin: const EdgeInsets.all(12.0),
                      child: InkWell(
                        onTap: () {
                          // ไปหน้า orderdetail ตอนกดคำสั่งซื้อ
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(order: order),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order Date: ${order.orderedAt}",
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Total Price: \$${order.totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Status: ${order.status}",
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
    );
  }
}