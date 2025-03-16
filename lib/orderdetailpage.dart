import 'package:flutter/material.dart';
import 'model/ordermodel.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Expanded( 
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Order Date: ${order.orderedAt}",
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,)
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Items",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  SizedBox(height: 10),
                  // สินค้าทั้งหมด
                  ...order.items.map((item) {
                    return ListTile(
                      leading: Image.network(
                        item.productImage,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported,
                              size: 100, color: Colors.grey);
                        },
                      ),
                      title: Text(item.productName),
                      subtitle: Text(
                          "Size: ${item.selectedSize}, Color: ${item.selectedColor}\nQuantity: ${item.quantity}",style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15
                          ),),
                      trailing: Text("\$${item.productPrice}", style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),),
                    );
                  }).toList(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)), // Subtle top border
              ),
              // รายละเอียดการซื่อ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow("OrderId:", order.orderId),
                  _buildRow("Total Price:", "\$${order.totalPrice.toStringAsFixed(2)}"),
                  _buildRow("Payment:", order.paymentMethod),
                  _buildRow("Status:", order.status),
                  _buildRow("Shipping:", order.shippingMethod),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 17,
            fontWeight: FontWeight.w500,
          )),
          Text(value, style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 17,
            fontWeight: FontWeight.w400,
          )),
        ],
      ),
    );
  }
}
