import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil package
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';
import 'package:thesis_establishment/Spending%20Analysis/Inputvalue.dart'; // Ensure correct path

class ScanQR extends StatefulWidget {
  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  int _selectedIndex = 0; // Default selection for bottom navigation bar
  String? scannedCode; // To store the scanned QR code
  bool _isNavigated = false; // Flag to prevent multiple navigations

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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), // Responsive padding
                child: Row(
                  children: [
                    // Back button with circle and "<" icon
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Navigate back
                      },
                      child: Container(
                        width: 40.w, // Responsive width
                        height: 40.h, // Responsive height
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6.0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Adding padding to move 'Scan QR' slightly to the left
                    Padding(
                      padding: EdgeInsets.only(left: 100.w), // Responsive padding
                      child: Text(
                        'Scan QR',
                        style: TextStyle(
                          fontSize: 24.sp, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR Scanner (MobileScanner widget)
                    Container(
                      width: 250.w, // Responsive width
                      height: 250.h, // Responsive height
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          onDetect: (BarcodeCapture barcodeCapture) {
                            if (_isNavigated) return; // Prevent multiple navigations

                            final List<Barcode> barcodes = barcodeCapture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null) {
                                setState(() {
                                  scannedCode = barcode.rawValue; // Store the scanned QR code
                                  _isNavigated = true; // Set the flag to true
                                });
                                print('QR Code found: $scannedCode');

                                // Navigate to the Inputvalue page after a short delay
                                Future.delayed(Duration(milliseconds: 500), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Inputvalue(scannedCode: scannedCode!),
                                    ),
                                  ).then((_) {
                                    // Reset the flag when returning to this page
                                    setState(() {
                                      _isNavigated = false;
                                      scannedCode = null; // Optional: Reset the scanned code
                                    });
                                  });
                                });

                                break; // Exit the loop after handling the first valid barcode
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18), // Space between the scanner and the text
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        scannedCode == null
                            ? 'Align frame with QR code'
                            : '', // Change this line to an empty string to hide the scanned code message
                        style: TextStyle(
                          color: Colors.grey[600], // Grey color for text
                          fontSize: 18.sp, // Responsive font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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