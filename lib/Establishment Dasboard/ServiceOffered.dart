import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';

class TouristServiceSelection extends StatefulWidget {
  @override
  _TouristServiceSelectionState createState() => _TouristServiceSelectionState();
}

class _TouristServiceSelectionState extends State<TouristServiceSelection> {
  int _currentScreen = 0; // 0 = Welcome, 1 = Selection, 2 = Review, 3 = Confirmation
  int _selectedIndex = 0;
  List<String> _selectedServices = [];

  
final List<Map<String, dynamic>> _services = [
  {"name": "Accommodation", "icon": Icons.hotel},
  {"name": "Food and Beverages", "icon": Icons.restaurant},
  {"name": "Transportation", "icon": Icons.directions_car},
  {"name": "Attractions and Activities", "icon": Icons.local_activity},
  {"name": "Shopping", "icon": Icons.shopping_bag},
  {"name": "Entertainment", "icon": Icons.theater_comedy},
  {"name": "Wellness and Spa Services", "icon": Icons.spa},
  {"name": "Adventure and Outdoor Activities", "icon": Icons.terrain},
  {"name": "Travel Insurance", "icon": Icons.shield},
  {"name": "Local Tours and Guides", "icon": Icons.tour},
];

    Future<void> _saveSelectedServices() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String email = user.email!;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("establishments");

    // Find the establishment by email and add the services
    final establishmentSnapshot = await dbRef.orderByChild('email').equalTo(email).get();

    if (establishmentSnapshot.exists) {
      final establishmentKey = establishmentSnapshot.children.first.key; // Get the unique key for the record
      await dbRef.child(establishmentKey!).update({
        "Services": _selectedServices,
      });
      print("Services updated successfully!");
    } else {
      print("No matching establishment found for this email.");
    }
  } else {
    print("No user is logged in.");
  }
}

  // Navigate to a specific screen
  void _showScreen(int screenIndex) {
    setState(() {
      _currentScreen = screenIndex;
    });
  }

  // Handle bottom navigation bar taps
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
          child: Container(
            padding: const EdgeInsets.all(20),
            child: _buildCurrentScreen(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.groups_3_outlined,
              color: Color(0xFF288F13),
            ),
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.black,
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

  // Build the appropriate screen based on _currentScreen
  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 0:
        return _buildWelcomeScreen();
      case 1:
        return _buildSelectionScreen();
      case 2:
        return _buildReviewScreen();
      case 3:
        return _buildConfirmationScreen();
      default:
        return _buildWelcomeScreen();
    }
  }

  Widget _buildWelcomeScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Select Offers for Your Tourists",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showScreen(1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF288F13),
          ),
          child: const Text("Choose Services for Tourists", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSelectionScreen() {
    return Column(
      children: [
        const Text(
          "Select Your Services for Tourists",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Choose the services you offer that will enhance tourists' experiences."),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              final isSelected = _selectedServices.contains(service["name"]);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedServices.remove(service["name"]);
                    } else {
                      _selectedServices.add(service["name"]);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF288F13) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        service["icon"],
                        color: isSelected ? Colors.white : Color(0xFF288F13),
                      ),
                      const SizedBox(width: 8),
                     Expanded(
                        child: Text(
                          service["name"],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5, // Increase this value to adjust font size
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedServices.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Please select at least one category."),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              _showScreen(2);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF288F13),
          ),
          child: const Text("Next", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildReviewScreen() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        "Review Tourist Services",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      const Text("Review the services selected for tourists. Click 'Save' to confirm or 'Back' to make changes."),
      const SizedBox(height: 20),
      Expanded(
        child: ListView(
          children: _selectedServices.map((service) {
            return ListTile(
              title: Text(service),
            );
          }).toList(),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _showScreen(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF288F13),
            ),
            child: const Text("Back", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveSelectedServices(); // Call the save function
              _showScreen(3); // Navigate to confirmation screen after saving
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF288F13),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildConfirmationScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Success!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Your services for tourists have been successfully saved!"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF288F13),
          ),
          child: const Text("Go to Dashboard", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
