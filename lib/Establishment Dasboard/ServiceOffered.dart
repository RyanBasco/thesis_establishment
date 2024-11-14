import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';

class TouristServiceSelection extends StatefulWidget {
  @override
  _TouristServiceSelectionState createState() =>
      _TouristServiceSelectionState();
}

class _TouristServiceSelectionState extends State<TouristServiceSelection> {
  int _currentScreen = 0; // 0 = Welcome, 1 = Selection, 2 = Review, 3 = Confirmation
  int _selectedIndex = 0;
  bool _hasServices = false; // Flag to determine if services exist
  List<String> _selectedServices = [];
  List<String> _historicalServices = []; // To hold previously selected services
  String _aboutEstablishment = ""; // To hold the user's "About the Establishment" input

  final TextEditingController _aboutController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _fetchHistoricalServices(); // Load historical data when the widget is initialized
  }

  Future<void> _fetchHistoricalServices() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      DatabaseReference dbRef = FirebaseDatabase.instance.ref("establishments");

      final establishmentSnapshot = await dbRef.orderByChild('email').equalTo(email).get();

      if (establishmentSnapshot.exists) {
        final establishmentData = establishmentSnapshot.children.first.value as Map;
        List<dynamic>? previousServices = establishmentData["Services"];

        if (previousServices != null && previousServices.isNotEmpty) {
          setState(() {
            _historicalServices = previousServices.cast<String>();
            _hasServices = true; // Set _hasServices to true if there are services
          });
        } else {
          setState(() {
            _hasServices = false; // No services, set _hasServices to false
          });
        }
      } else {
        print("No matching establishment found for this email.");
      }
    } else {
      print("No user is logged in.");
    }
  }

  Future<void> _saveSelectedServices() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      DatabaseReference dbRef = FirebaseDatabase.instance.ref("establishments");

      // Find the establishment by email and add the services and about text
      final establishmentSnapshot = await dbRef.orderByChild('email').equalTo(email).get();

      if (establishmentSnapshot.exists) {
        final establishmentKey = establishmentSnapshot.children.first.key;

        // Update Firebase with both selected services and the "About" information
        await dbRef.child(establishmentKey!).update({
          "Services": _selectedServices,
          "About": _aboutEstablishment, // Save "About the Establishment" under About key
        });
        print("Services and About information updated successfully!");
      } else {
        print("No matching establishment found for this email.");
      }
    } else {
      print("No user is logged in.");
    }
  }

  void _showScreen(int screenIndex) {
    setState(() {
      _currentScreen = screenIndex;
    });
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

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EstablishmentProfile()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside the text field
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildCurrentScreen(),
          ),
        ),
        bottomNavigationBar: _hasServices
            ? BottomNavigationBar(
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
              )
            : null, // Conditionally render the bottom navigation bar
      ),
    );
  }

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
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(top: 10), // Padding to move down the content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back button with adjustable padding
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 10), // Adjust these values to position manually
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Navigate back to the previous screen
                },
                child: Container(
                  width: 40,
                  height: 40,
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
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select Offers for Your Tourists",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "About the Establishment",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _aboutController,
            onChanged: (value) {
              _aboutEstablishment = value;
            },
            decoration: const InputDecoration(
              hintText: "About the establishment...",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          if (_historicalServices.isNotEmpty)
            Column(
              children: [
                const Text(
                  "Previously Selected Services:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _historicalServices.map((service) {
                    return Chip(
                      label: Text(service),
                      backgroundColor: Color(0xFF288F13),
                      labelStyle: TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          const SizedBox(height: 30), // Additional padding to move down the button
          ElevatedButton(
            onPressed: () => _showScreen(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF288F13),
            ),
            child: const Text("Choose Services for Tourists",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}


 Widget _buildSelectionScreen() {
  return Padding(
    padding: const EdgeInsets.only(top: 50), // Padding to move down the title
    child: Column(
      children: [
        const Text(
          "Select Your Services for Tourists",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Choose the services you offer that will enhance tourists' experiences."
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true, // Ensures grid does not scroll independently
          physics: NeverScrollableScrollPhysics(),
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
                          fontSize: 12.5,
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
        const SizedBox(height: 30), // Padding to move down the button row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _showScreen(0), // Navigate back to previous screen
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF288F13),
              ),
              child: const Text("Back", style: TextStyle(color: Colors.white)),
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
                  _showScreen(2); // Navigate to the next screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF288F13),
              ),
              child: const Text("Next", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildReviewScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Review Tourist Services",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Review the services selected for tourists. Click 'Save' to confirm or 'Back' to make changes.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_aboutEstablishment.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About the Establishment:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF288F13),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _aboutEstablishment,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selected Services:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF288F13),
                  ),
                ),
                const SizedBox(height: 10),
                ..._selectedServices.map((serviceName) {
                  final service = _services.firstWhere(
                    (s) => s['name'] == serviceName,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          service['icon'],
                          color: Color(0xFF288F13),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          service['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _showScreen(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF288F13),
                ),
                child: const Text("Back", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _saveSelectedServices();
                  _showScreen(3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF288F13),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
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
