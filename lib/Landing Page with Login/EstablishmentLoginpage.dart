import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentSignuppage.dart';

class EstablishmentLogin extends StatefulWidget {
  @override
  _EstablishmentLoginState createState() => _EstablishmentLoginState();
}

class _EstablishmentLoginState extends State<EstablishmentLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // For toggling password visibility

  // Function to handle login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error messages
    });

    try {
      // Check if the email exists in Firestore
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('establishments')
          .where('email', isEqualTo: _emailController.text)
          .get();

      if (result.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid Email or Password.';
          _isLoading = false;
        });
        return; // Exit if no establishment is found
      }

      // Sign in with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If login is successful, navigate to the DashboardPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
        _isLoading = false; // Stop the loading spinner
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEEFFA9),
              Color(0xFFDBFF4C),
              Color(0xFF51F643),
            ],
            stops: [0.15, 0.54, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0), // Adjust this value to move down
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/building.png', height: 150),
                  ),
                  SizedBox(height: 40),

                  // "Login" Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF288F13), // Color #288F13
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field with Icon
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF288F13), // Background color for email field
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.email, color: Colors.white), // Email Icon
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white), // White text inside
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field with Eye Icon
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF288F13), // Background color for password field
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.lock, color: Colors.white), // Lock Icon
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword; // Toggle password visibility
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white), // White text inside
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Error message if any
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Forgot password? text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.black, // Black text color
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Login Button with loading indicator
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show loading spinner when signing in
                        : ElevatedButton(
                            onPressed: _login, // Call the login function
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF288F13), // Button color
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Increased size
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white, // Button text color
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
