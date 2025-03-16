import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model/productmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isLoading = false;
  String? _selectedSize; 
  String? _selectedColor;
  bool _isSizeListExpanded = false; 
  bool _isColorListExpanded = false;

  // ลิส size กับสี
  final List<String> _sizes = ['6', '7', '8', '9', '10', '11', '12', '13'];
  final List<String> _colors = ['Red', 'White', 'Black', 'Green'];

  // ดึง userid
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // func เพิ่มข้อมูลใน cart
  Future<void> _addToCart() async {
    if (_selectedSize == null || _selectedColor == null) {
      Fluttertoast.showToast(
        msg: "Please select size and color",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      String? userId = getCurrentUserId(); // ดึง User ID ของผู้ใช้ปัจจุบัน
      if (userId == null) {
        Fluttertoast.showToast(
        msg: "User not logged in",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontAsset: 'Outfit',
        textColor: Colors.white,
        fontSize: 16.0
    );
        return;
      }

      await FirebaseFirestore.instance.collection('cart').add({
        'productId': widget.product.productid,
        'productName': widget.product.name,
        'productPrice': widget.product.price,
        'productImage': widget.product.imageUrl,
        'selectedSize': _selectedSize, 
        'selectedColor': _selectedColor, 
        'addedAt': DateTime.now(),
        'userId': userId, 
      });

      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "${widget.product.name} add to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontAsset: 'Outfit',
        textColor: Colors.white,
        fontSize: 16.0
    );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "'Error: $e'",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontAsset: 'Outfit',
        textColor: Colors.white,
        fontSize: 16.0
    );


    }
  }

  // ฟังชันเพิ่มสินค้า wish
  Future<void> _addToWishlist() async {

    try {
      setState(() {
        _isLoading = true;
      });

      String? userId = getCurrentUserId(); // ดึง User ID ของผู้ใช้ปัจจุบัน
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('wishlist').add({
        'productId': widget.product.productid,
        'productName': widget.product.name,
        'productPrice': widget.product.price,
        'productImage': widget.product.imageUrl,
        'selectedSize': _selectedSize, 
        'selectedColor': _selectedColor, 
        'addedAt': DateTime.now(),
        'userId': userId, 
        'brand': widget.product.brand, 
        'description': widget.product.description,
      });

      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "${widget.product.name} add to wishlist",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontAsset: 'Outfit',
        textColor: Colors.white,
        fontSize: 16.0
    );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.product.brand,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.product.imageUrl),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: true,  
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              const Divider(  
                color: Colors.grey,  
                thickness: 1,  
                height: 20,  
              ),
              const SizedBox(height: 10),
              Text(
                'Description',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.product.description,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 87, 87, 87),
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 20,),
              const Divider(  
                color: Colors.grey,  
                thickness: 1,  
                height: 20,  
              ),
              ListTile(
                title: Text(
                  'Select Size',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  _isSizeListExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black,
                ),
                onTap: () {
                  setState(() {
                    _isSizeListExpanded =
                        !_isSizeListExpanded;
                  });
                },
              ),
              
              // แสดง size รองเท้า
              if (_isSizeListExpanded) ...[
                const SizedBox(height: 10),
                Wrap(
                  alignment:
                      WrapAlignment.center, 
                  spacing: 13, 
                  runSpacing: 15, 
                  children: _sizes.map((size) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSize = size;
                        });
                      },
                      child: Container(
                        width: 75,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedSize == size
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedSize == size
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : Colors.white,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(0, 4),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Text(
                          size,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _selectedSize == size
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  'Select Color',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  _isColorListExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black,
                ),
                onTap: () {
                  setState(() {
                    _isColorListExpanded =
                        !_isColorListExpanded; 
                  });
                },
              ),
              // แสดงสีรองเท้า
              if (_isColorListExpanded) ...[
                const SizedBox(height: 10),
                Wrap(
                  alignment:
                  WrapAlignment.center, 
                  spacing: 13, 
                  runSpacing: 15, 
                  children: _colors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color; 
                        });
                      },
                      child: Container(
                        width: 75,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedColor == color
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedColor == color
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : Colors.white,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(0, 4),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Text(
                          color,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _selectedColor == color
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              // ปุ่ม add cart
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addToWishlist,
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "Add to Wishlist",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: Colors.grey, 
                        width: 1, 
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Add to Cart \$${widget.product.price}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}