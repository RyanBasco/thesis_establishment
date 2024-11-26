import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Analytics.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/GenerateQR.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/ServiceOffered.dart';
import 'package:thesis_establishment/Records/Historytable.dart';
import 'package:thesis_establishment/Records/Records.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Review.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/ScanQR.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';
import 'package:thesis_establishment/Records/Transactionslip.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String _searchQuery = "";
  String establishmentName = 'Loading...';

  final List<Map<String, dynamic>> _boxes = [
  {'title': 'Scan QR', 'icon': Icons.qr_code},
  {'title': 'Service Offered', 'icon': Icons.miscellaneous_services}, // New Box Added
  {'title': 'Generate QR', 'icon': Icons.qr_code_scanner},
  {'title': 'Records', 'icon': Icons.receipt},
  {'title': 'Sales', 'icon': Icons.store},
  {'title': 'Review', 'icon': Icons.announcement},
];

  @override
  void initState() {
    super.initState();
    fetchEstablishmentName();
  }

  void fetchEstablishmentName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;
      String email = refreshedUser?.email ?? '';
      print('Fetching establishment for email: $email');

      try {
        // Reference to the Realtime Database
        DatabaseReference dbRef =
            FirebaseDatabase.instance.ref('establishments');

        // Retrieve data where email matches
        DatabaseEvent event =
            await dbRef.orderByChild('email').equalTo(email).once();

        if (event.snapshot.exists) {
          // Since we're expecting one match, take the first entry
          var establishmentData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          var firstRecord = establishmentData.values.first;

          setState(() {
            establishmentName =
                firstRecord['establishmentName'] ?? 'No Name Available';
          });
          print('Establishment name found: $establishmentName');
        } else {
          setState(() {
            establishmentName = 'Establishment not found';
          });
          print('No establishment found for this email.');
        }
      } catch (e) {
        setState(() {
          establishmentName = 'Error fetching establishment';
        });
        print('Error fetching establishment: $e');
      }
    } else {
      setState(() {
        establishmentName = 'User not logged in';
      });
    }
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _navigateToScanQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanQR()),
    );
  }

  void _navigateToGenerateQR(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenerateQR()),
    );
  }

  void _navigateToRecords(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => History()),
    );
  }

  void _navigateToReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Review()),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Analytics()),
    );
  }

  void _navigateToServiceOffered (BuildContext context){
    Navigator.push(context,
     MaterialPageRoute(builder: (context) => TouristServiceSelection())
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBoxes = _boxes.where((box) {
      return box['title']!.toLowerCase().contains(_searchQuery);
    }).toList();

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
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        establishmentName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 14.h, horizontal: 16.w),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 24.h),
                ...filteredBoxes.map((box) {
                  return GestureDetector(
                    onTap: () {
                      if (box['title'] == 'Scan QR') {
                        _navigateToScanQR(context);
                      } else if (box['title'] == 'Generate QR') {
                        _navigateToGenerateQR(context);
                      } else if (box['title'] == 'Records') {
                        _navigateToRecords(context);
                      } else if (box['title'] == 'Review') {
                        _navigateToReview(context);
                      } else if (box['title'] == 'Sales') {
                        _navigateToAnalytics(context);
                      } else if (box['title'] == 'Service Offered') {
                        _navigateToServiceOffered(context);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150.h,
                      padding: EdgeInsets.all(20.w),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFF288F13),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              box['icon'],
                              color: Colors.white,
                              size: 50.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  box['title'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black,
                                  size: 24.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20.h),
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
            icon: Icon(Icons.groups_3_outlined,
                color: _selectedIndex == 0 ? Color(0xFF288F13) : Colors.black),
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 1 ? Color(0xFF288F13) : Colors.black),
            label: 'Personal',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
