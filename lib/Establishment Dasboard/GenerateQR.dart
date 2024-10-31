import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil package
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart'; // QR code package

class GenerateQR extends StatefulWidget {
  @override
  _GenerateQRState createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  int _selectedIndex = 0; // Default selection for bottom navigation bar
  String email = '';
  String establishmentName = 'Loading...'; // Placeholder text
  String documentId = ''; // Variable to store the document ID

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch Firestore data based on email when page loads
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EstablishmentProfile()), // Navigate to EstablishmentProfile
      );
    }
  }

  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> fetchData() async {
  // Get the current user's email
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    email = user.email ?? '';

    // Fetch the establishment from Firestore using the email
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('establishments')
        .where('email', isEqualTo: email)
        .get();

    if (mounted) { // Check if the widget is still mounted before calling setState
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          establishmentName = snapshot.docs.first['establishmentName'] ?? 'No Name Available';
          documentId = snapshot.docs.first.id; // Store the document ID
        });
      } else {
        setState(() {
          establishmentName = 'Establishment not found';
        });
      }
    }
  } else {
    if (mounted) {
      setState(() {
        establishmentName = 'User not logged in';
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
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
          child: Padding(
            padding: EdgeInsets.all(16.0.w), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _navigateBack(context);
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 70.w),
                    Text(
                      'Generate QR',
                      style: TextStyle(
                        fontSize: 24.sp, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h), // Responsive height
                Container(
                  width: double.infinity,
                  height: 350.h, // Responsive height
                  padding: EdgeInsets.all(20.0.w), // Responsive padding inside the white box
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r), // Responsive radius
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      email.isEmpty
                          ? CircularProgressIndicator() // Show loading until the data is fetched
                          : QrImageView(
                              data: documentId, // Use the document ID for the QR code
                              version: QrVersions.auto,
                              size: 200.w, // Responsive size
                            ),
                      SizedBox(height: 20.h), // Space between QR code and text
                      Text(
                        establishmentName, // Display establishment name below QR code
                        style: TextStyle(
                          fontSize: 25.sp, // Responsive font size
                          fontWeight: FontWeight.bold, // Made the text bold
                          color: Color(0xFF288F13), // Changed color to 0xFF288F13
                        ),
                        textAlign: TextAlign.center, // Center the text inside the box
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h), // Responsive height
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.groups_3_outlined,
              color: _selectedIndex == 0 ? Color(0xFF288F13) : Colors.black,
            ),
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 1 ? Color(0xFF288F13) : Colors.black,
            ),
            label: 'Personal',
            backgroundColor: Colors.white,
          ),
        ],
        selectedItemColor: Color(0xFF288F13),
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 8.0,
      ),
    );
  }
}
