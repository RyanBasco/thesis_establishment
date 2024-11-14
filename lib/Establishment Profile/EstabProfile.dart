import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Establishment%20Profile/EditProfile.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentLoginpage.dart';

class EstablishmentProfile extends StatefulWidget {
  @override
  _EstablishmentProfileState createState() => _EstablishmentProfileState();
}

class _EstablishmentProfileState extends State<EstablishmentProfile> {
  int _selectedIndex = 1;
  String establishmentName = 'Loading...';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchEstablishmentData();
    fetchProfileImageUrl();
  }

  void fetchEstablishmentData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments');
      DatabaseEvent event =
          await dbRef.orderByChild('email').equalTo(email).once();

      if (event.snapshot.exists) {
        var establishmentData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        var firstRecord =
            Map<String, dynamic>.from(establishmentData.values.first as Map);
        setState(() {
          establishmentName =
              firstRecord['establishmentName'] ?? 'No Name Available';
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

  Future<void> fetchProfileImageUrl() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String filePath =
            'Establishment/${user.uid}/profile_image/latest_image.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
        String downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print('Error fetching profile image: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
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
            colors: [Color(0xFFEEFFA9), Color(0xFFDBFF4C), Color(0xFF51F643)],
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
              height: 400,
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
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            image: profileImageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(profileImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profileImageUrl == null
                              ? Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 50,
                                )
                              : null,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            establishmentName,
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
                  SizedBox(height: 16),
                  buildCircleRow('Edit Profile', Icons.edit, Colors.black,
                      () async {
                    final updatedProfileImageUrl = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );

                    if (updatedProfileImageUrl != null) {
                      setState(() {
                        profileImageUrl = updatedProfileImageUrl;
                      });
                    }
                  }),
                  SizedBox(height: 16),
                  buildCircleRow('Log Out', Icons.logout, Colors.red, () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EstablishmentLogin()),
                      (Route<dynamic> route) =>
                          false, // Clears all previous routes
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

  Widget buildCircleRow(
      String label, IconData icon, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
                SizedBox(width: 16),
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
