import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_project/Editprofile.dart';
import 'package:shop_project/Login.dart';
import 'package:shop_project/model/usermodel.dart';
import 'package:shop_project/notificationpages.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserModel? usermodel;

  bool isEditing = false; 
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // update
  Future<void> updateUserData() async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': nameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
    }, SetOptions(merge: true));

    setState(() {
      usermodel?.name = nameController.text;
      usermodel?.phone = phoneController.text;
      usermodel?.address = addressController.text;
      isEditing = false; 
    });
  }

  // fetch user na
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
        nameController.text = usermodel?.name ?? "";
        phoneController.text = usermodel?.phone ?? "";
        addressController.text = usermodel?.address ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              auth.signOut().then((onValue) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return Login();
                }));
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              const Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      "https://www.shutterstock.com/image-vector/avatar-gender-neutral-silhouette-vector-600nw-2470054311.jpg",
                    ),
                  ),
                  const SizedBox(height: 20),
                  isEditing
                      ? TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Name",
                          ),
                        )
                      : Text(
                          usermodel?.name ?? "No Name",
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  // ปุ่ม editpro
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // ไปหน้า editpro
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfile()),
                      );
                      if (result == true) {
                        fetchUserData(); // fetch ข้อมูล user ใหม่
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Set background color
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // Rounded corners
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 15), // Button padding
                      ),
                    ),
                    child: const Text("Edit Profile", style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 255, 255),
                    )),
                  ),
                ],
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.black),
                    title: const Text("Email", style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                    )),
                    subtitle: Text(auth.currentUser?.email ?? 'No Email', style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                    )),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.black),
                    title: const Text("Phone", style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                    )),
                    subtitle: isEditing
                        ? TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Phone",
                            ),
                          )
                        : Text(usermodel?.phone ?? 'No Phone', style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                        )),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.black),
                    title: const Text("Address", style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                    )),
                    subtitle: isEditing
                        ? TextField(
                            controller: addressController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Address",
                            ),
                          )
                        : Text(usermodel?.address ?? 'No Address', style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                        )),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.black),
                    title: const Text(
                      "Notification",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
