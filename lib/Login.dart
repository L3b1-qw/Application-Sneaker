import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'Homepage.dart';
import 'RegisterPage.dart';
import 'model/profile.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  Profile profile = Profile(email: '', password: '', confirmpassword: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 45,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Account Log In",
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 25,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 30),
                  // กรอก email
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Email",
                      suffixIcon: const Icon(Icons.email,color: Colors.black,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Please input Email"),
                      EmailValidator(errorText: "Your Email don't match.")
                    ]),
                    onSaved: (email) {
                      profile.email = email ?? "";
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  // กรอก password
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Password",
                      suffixIcon: const Icon(Icons.lock,color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    obscureText: true,
                    validator: RequiredValidator(errorText: "Please input Password."),
                    onSaved: (password) {
                      profile.password = password ?? "";
                    },
                  ),
                  const SizedBox(height: 20),

                  // ปุ้ม login
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: profile.email,
                                    password: profile.password)
                                .then((onValue) {
                              _formKey.currentState?.reset();
                              Fluttertoast.showToast(
                                msg: "Login Success!!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return Homepage();
                              }));
                            });
                          } on FirebaseAuthException catch (error) {
                            Fluttertoast.showToast(
                              msg: error.message ?? "An error occurred",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 0, 0)), // Set background color
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(vertical: 9, horizontal: 153), // Button padding
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ปุ่ม Register
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Color.fromARGB(255, 44, 44, 44), 
                          fontSize: 16),
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // ไปหน้า regist
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return RegisterPage();
                                })); 
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}