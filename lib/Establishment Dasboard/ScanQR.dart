import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';
import 'package:thesis_establishment/Spending%20Analysis/Inputvalue.dart';

class ScanQR extends StatefulWidget {
  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  int _selectedIndex = 0;
  String? scannedCode;
  bool _isNavigated = false;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EstablishmentProfile()),
      );
    }
  }

  Future<void> _createPendingReview(String userId) async {
    final User? user = _auth.currentUser;
    final String? establishmentId = user?.uid;

    if (establishmentId != null) {
      await _databaseRef.child('pendingReviews/$userId').set({
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'establishment_id': establishmentId,
      });
    } else {
      print("No establishment ID found. Please ensure you're logged in.");
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
            colors: [Color(0xFFEEFFA9), Color(0xFFDBFF4C), Color(0xFF51F643)],
            stops: [0.15, 0.54, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.h,
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
                    Padding(
                      padding: EdgeInsets.only(left: 100.w),
                      child: Text(
                        'Scan QR',
                        style: TextStyle(
                          fontSize: 24.sp,
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
                    Container(
                      width: 250.w,
                      height: 250.h,
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
                            if (_isNavigated) return;

                            final List<Barcode> barcodes = barcodeCapture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null) {
                                setState(() {
                                  scannedCode = barcode.rawValue;
                                  _isNavigated = true;
                                });
                                print('QR Code found: $scannedCode');
                                _createPendingReview(scannedCode!);

                                Future.delayed(Duration(milliseconds: 500), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Inputvalue(scannedCode: scannedCode!),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      _isNavigated = false;
                                      scannedCode = null;
                                    });
                                  });
                                });
                                break;
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        scannedCode == null ? 'Align frame with QR code' : '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18.sp,
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
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 1 ? Color(0xFF288F13) : Colors.black,
            ),
            label: 'Personal',
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
