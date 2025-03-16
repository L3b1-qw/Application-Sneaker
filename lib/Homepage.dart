import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_project/WishlistPage.dart';
import 'ProductDetailPage.dart';
import 'Profilepage.dart';
import 'CartsPage.dart';  
import 'model/productmodel.dart';
import 'model/usermodel.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  UserModel? usermodel;
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController addressController = TextEditingController();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(usermodel: usermodel),
      const Profilepage(),
    ];
    fetchUserData(); // รีข้อมูล user
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> updateUserData() async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'address': addressController.text,
    }, SetOptions(merge: true));

    setState(() {
      usermodel?.address = addressController.text;
    });
  }

  Future<void> fetchUserData() async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        usermodel =
            UserModel.fromMap(uid, userDoc.data() as Map<String, dynamic>);
        _pages[0] = HomeScreen(usermodel: usermodel); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // รีข้อมูล
          if (index == 0) {
            fetchUserData();
          }
        },
        selectedLabelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.bold, 
          fontSize: 14,
          color: const Color.fromARGB(255, 0, 0, 0)), 
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 12,
          color: const Color.fromARGB(255, 0, 0, 0)), 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final UserModel? usermodel;

  const HomeScreen({super.key, this.usermodel});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ดึงadidas
  String _selectedBrand = 'Adidas'; 

  // ฟัง เปลี่ยนยี่ห้อ
  void _changeBrand(String brand) {
    setState(() {
      _selectedBrand = brand; // Change the selected brand
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return WishlistPage();
              }),
            );
          },
          icon: const Icon(Icons.favorite, color: Colors.white),
        ),
        title: Center(
          child: RichText(
            textAlign: TextAlign.center, // Ensures text is centered within RichText
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                const TextSpan(
                  text: "Delivery Address\n",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: widget.usermodel?.address ?? 'No Address',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(width: 48),
        ],
      ),


      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.fromLTRB(18, 20, 0, 15),
              child: const Text(
                "Brands",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ปุ่ม Adidas 
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _changeBrand('Nike');
                    },
                    icon: Image.asset(
                      'assets/images/nike.png',
                      height: 30,
                    ),
                  ),
                ),
                // ปุ่ม Nike
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _changeBrand('Adidas');
                    },
                    icon: Image.asset(
                      'assets/images/adidas1.png',
                      height: 15,
                    ),
                  ),
                ),
                // ปุ่ม converse
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _changeBrand('Converse');
                    },
                    icon: Image.asset(
                      'assets/images/converse1.png',
                      height: 18,
                    ),
                  ),
                ),
                // ปุ่ม jordan
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _changeBrand('Jordan');
                    },
                    icon: Image.asset(
                      'assets/images/aj.png',
                      height: 25,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('products')
                    .where('brand', isEqualTo: _selectedBrand) 
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products available'));
                  }

                  var products = snapshot.data!.docs.map((doc) {
                    return Product.fromFirestore(
                        doc.data() as Map<String, dynamic>);
                  }).toList();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return productCard(context, products[index], index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ปุ่มลอย cart
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return CartsPage();
            }),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


// card
Widget productCard(BuildContext context, Product product, int index) {
  return GestureDetector(
    onTap: () {
      // ไปหน้า product
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(product: product),
        ),
      );
    },
    child: Card(
      color: Colors.grey[100],
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '\$${product.price.toString()}',
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    ),
  );
}
