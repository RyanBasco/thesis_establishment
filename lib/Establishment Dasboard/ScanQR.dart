import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';
import 'package:thesis_establishment/Spending%20Analysis/Inputvalue.dart';

class ScanQR extends StatefulWidget {
  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  String? scannedCode;
  bool _isNavigated = false;
  MobileScannerController scannerController = MobileScannerController();
  bool isValidQRCode = true; // New variable to track QR code validity
  bool _isShowingDialog = false; // Add this flag

  void _reinitializeCamera() {
    try {
      // Stop and dispose old controller
      scannerController.stop();
      scannerController.dispose();
      // Create and start new controller
      scannerController = MobileScannerController();
      if (mounted) {
        scannerController.start();
      }
    } catch (e) {
      print('Error reinitializing camera: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reinitializeCamera();
  }

  @override
  void dispose() {
    // Stop the camera before disposing
    scannerController.stop();
    // Dispose the controller
    scannerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _reinitializeCamera();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        scannerController.stop();
        break;
      default:
        break;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    scannerController.start();
  }

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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardPage(),
                          ),
                        );
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
                          controller: scannerController,
                          errorBuilder: (context, error, child) {
                            return Center(
                              child: IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _reinitializeCamera,
                              ),
                            );
                          },
                          onDetect: (BarcodeCapture barcodeCapture) {
                            if (_isNavigated) return;

                            final List<Barcode> barcodes =
                                barcodeCapture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null) {
                                final scannedValue = barcode.rawValue!;

                                // Validate if the scanned value is a Firebase UID (typically 28 characters)
                                if (scannedValue.length >= 20) {  // Firebase UIDs are long strings
                                  setState(() {
                                    scannedCode = scannedValue;
                                    _isNavigated = true;
                                    isValidQRCode = true;
                                  });
                                  print('Valid QR Code found: $scannedCode');

                                  // Navigate to the next page
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Inputvalue(
                                          scannedCode: scannedCode!,
                                        ),
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        _isNavigated = false;
                                        scannedCode = null;
                                        scannerController
                                            .start(); // Restart the scanner
                                      });
                                    });
                                  });
                                } else {
                                  // Invalid QR Code
                                  if (!_isShowingDialog) {
                                    setState(() {
                                      isValidQRCode = false;
                                      _isShowingDialog = true;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Invalid QR Code'),
                                          content: const Text('Please scan a valid QR code from the application.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  _isShowingDialog = false;
                                                });
                                                scannerController.start();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  print('Invalid QR Code scanned');
                                }
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
                        scannedCode == null
                            ? 'Align frame with a valid QR code'
                            : isValidQRCode
                                ? 'Valid QR code scanned!'
                                : 'Invalid QR code scanned!',
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
