import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Establishment%20Profile/EditProfile.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentLoginpage.dart';

class EstablishmentProfile extends StatefulWidget {
  @override
  _EstablishmentProfileState createState() => _EstablishmentProfileState();
}

class _EstablishmentProfileState extends State<EstablishmentProfile> {
  int _selectedIndex = 1; // Default selection for bottom navigation bar
  String establishmentName = 'Loading...'; // Placeholder for establishment name

  @override
  void initState() {
    super.initState();
    fetchEstablishmentName(); // Fetch establishment name on init
  }

  void fetchEstablishmentName() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String email = user.email ?? '';

    // Reference to Firebase Realtime Database
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments');

    // Fetch establishment based on the email using a query
    DatabaseEvent event = await dbRef.orderByChild('email').equalTo(email).once();

    if (event.snapshot.exists) {
      // Safely convert the snapshot value to Map<String, dynamic>
      var establishmentData = Map<String, dynamic>.from(event.snapshot.value as Map);
      var firstRecord = Map<String, dynamic>.from(establishmentData.values.first as Map);

      setState(() {
        establishmentName = firstRecord['establishmentName'] ?? 'No Name Available';
      });
    } else {
      setState(() {
        establishmentName = 'Establishment not found';
      });
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

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()), // Navigate to DashboardPage
      );
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              height: 400, // Adjust height as needed
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                      left: 24.0,
                      right: 16.0,
                      bottom: 24.0,
                    ), // Adjusted padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          ),
                          padding: EdgeInsets.all(16.0),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            establishmentName, // Display the establishment name
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF288F13),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16), // Spacer between profile and circles
                  // First circle with Edit Profile
                  buildCircleRow('Edit Profile', Icons.edit, Colors.black, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfile()),
                    );
                  }),
                  SizedBox(height: 16),
                  // Third circle with Log Out
                  buildCircleRow('Log Out', Icons.logout, Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EstablishmentLogin()),
                    );
                  }),
                ],
              ),
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

  // Updated method to include navigation callback
  Widget buildCircleRow(String label, IconData icon, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Handle circle row tap
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF288F13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16), // Space between circle and text
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
