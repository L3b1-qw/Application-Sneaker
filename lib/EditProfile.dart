import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // ดึงข้อมูลของ user
  Future<void> fetchUserData() async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        nameController.text = userData.containsKey('name') ? userData['name'] : '';
        phoneController.text = userData.containsKey('phone') ? userData['phone'] : '';
        addressController.text = userData.containsKey('address') ? userData['address'] : '';
      });
    }
  }

  // update ข้อมูล user
  Future<void> updateUserData() async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
      }, SetOptions(merge: true));

      Navigator.pop(context, true);  
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500, 
            color: Colors.black,
            fontFamily: 'Outfit'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Center( // Centering the profile picture
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  "https://www.shutterstock.com/image-vector/avatar-gender-neutral-silhouette-vector-600nw-2470054311.jpg",
                ),
              ),
            ),
              SizedBox(height: 25,),
            Text(
              'Name',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left, 
            ),
            SizedBox(height: 8),
            // กรอกชื่อ
            TextField(
              controller: nameController,
              textAlign: TextAlign.start, 
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.black,), 
                hintText: 'Enter your name',
                hintStyle: TextStyle(
                  fontFamily: 'Outfit'
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 20),
            // กรอกเบอร์
            Text(
              'Phone',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left, // Align the label to the left
            ),
            TextField(
              controller: phoneController,
              textAlign: TextAlign.start, // Align text to start
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone, color: Colors.black), // Icon before the text
                hintText: 'Enter your phone number ',
                hintStyle: TextStyle(
                  fontFamily: 'Outfit'
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 20),
            // กรอกที่อยู่
            Text(
              'Address',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left, // Align the label to the left
            ),
            TextField(
              controller: addressController,
              textAlign: TextAlign.start, // Align text to start
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on, color: Colors.black), // Icon before the text
                hintText: 'Enter your address',
                hintStyle: TextStyle(
                  fontFamily: 'Outfit'
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 30),
            // ปุ่ม save
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Set background color
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // Rounded corners
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(vertical: 9, horizontal: 153), // Button padding
                ),
              ),
              // กด save update ข้อมูล
              onPressed: updateUserData,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}