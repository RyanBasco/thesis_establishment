import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/ScanQR.dart';

class Inputvalue extends StatefulWidget {
  final String scannedCode;

  const Inputvalue({Key? key, required this.scannedCode}) : super(key: key);

  @override
  _InputvalueState createState() => _InputvalueState();
}

class _InputvalueState extends State<Inputvalue> {
  final TextEditingController _totalSpendController = TextEditingController();
  String? fullName;
  String? selectedCategory;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> filteredCategories = []; // Stores categories filtered based on selected services

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchEstablishmentServices(); // Fetch services selected by the establishment
  }

  // Fetch user details from 'Users' node
  void fetchUserData() async {
    String documentID = widget.scannedCode.trim();
    DatabaseReference userRef = FirebaseDatabase.instance.ref('Users/$documentID');
    DatabaseEvent event = await userRef.once();

    if (event.snapshot.exists) {
      final userData = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        String firstName = userData['first_name'] ?? 'N/A';
        String lastName = userData['last_name'] ?? 'N/A';
        fullName = '$firstName $lastName';
      });
    } else {
      setState(() {
        fullName = 'User not found';
      });
    }
  }

  // Fetch establishment's selected services from 'establishments' node
  Future<void> fetchEstablishmentServices() async {
    final userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      DatabaseReference establishmentRef = FirebaseDatabase.instance.ref('establishments');
      DataSnapshot establishmentSnapshot = await establishmentRef.orderByChild('email').equalTo(userEmail).get();

      if (establishmentSnapshot.exists) {
        var establishmentData = Map<String, dynamic>.from(establishmentSnapshot.value as Map);
        String establishmentKey = establishmentData.keys.first;
        var establishmentDetails = establishmentData[establishmentKey];
        List<dynamic> services = establishmentDetails['Services'] ?? [];

        setState(() {
          filteredCategories = List<String>.from(services); // Set the filtered categories
        });
      } else {
        print("Establishment not found for this user.");
      }
    } else {
      print("No authenticated user found.");
    }
  }

  // Create pending review after saving data
  Future<void> _createPendingReview(String userId) async {
    final User? user = _auth.currentUser;
    final String? establishmentId = user?.uid;

    if (establishmentId != null) {
      await FirebaseDatabase.instance.ref().child('pendingReviews/$userId').set({
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'establishment_id': establishmentId,
      });
    } else {
      print("No establishment ID found. Please ensure you're logged in.");
    }
  }

  // Save data to the 'Visits' node
  Future<void> saveData() async {
    final userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      final totalSpend = _totalSpendController.text.trim();
      if (totalSpend.isNotEmpty && fullName != null) {
        setState(() {
          isLoading = true;
        });

        final now = DateTime.now();
        String documentID = widget.scannedCode.trim();
        DatabaseReference visitsRef = FirebaseDatabase.instance.ref('Visits').push();
        DatabaseReference establishmentRef = FirebaseDatabase.instance.ref('establishments');
        DataSnapshot establishmentSnapshot = await establishmentRef.orderByChild('email').equalTo(userEmail).get();

        if (establishmentSnapshot.exists) {
          var establishmentData = Map<String, dynamic>.from(establishmentSnapshot.value as Map);
          String establishmentDocID = establishmentData.keys.first;
          var establishmentDetails = establishmentData[establishmentDocID];

          DatabaseReference userRef = FirebaseDatabase.instance.ref('Users/$documentID');
          DatabaseEvent userEvent = await userRef.once();
          if (userEvent.snapshot.exists) {
            var userDetails = Map<String, dynamic>.from(userEvent.snapshot.value as Map);

            await visitsRef.set({
              'TotalSpend': double.tryParse(totalSpend),
              'Category': selectedCategory,
              'Date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
              'Time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
              'User': {
                'UID': documentID,
                'first_name': userDetails['first_name'],
                'last_name': userDetails['last_name'],
                'birthday': userDetails['birthday'],
                'city': userDetails['city'],
                'civil_status': userDetails['civil_status'],
                'contact_number': userDetails['contact_number'],
                'countryOfResidence': userDetails['countryOfResidence'],
                'email': userDetails['email'],
                'nationality': userDetails['nationality'],
                'province': userDetails['province'],
                'purpose_of_travel': userDetails['purpose_of_travel'],
                'region': userDetails['region'],
                'sex': userDetails['sex']
              },
              'Establishment': {
                'EstablishmentID': establishmentDocID,
                'barangay': establishmentDetails['barangay'],
                'city': establishmentDetails['city'],
                'contact': establishmentDetails['contact'],
                'email': establishmentDetails['email'],
                'establishmentName': establishmentDetails['establishmentName'],
                'subCategory': establishmentDetails['subCategory'],
                'tourismType': establishmentDetails['tourismType']
              }
            });

            await _createPendingReview(documentID);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data saved successfully!')),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ScanQR()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data not found.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Establishment not found for this user.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the total spend and ensure the full name is available.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found.')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayName = fullName ?? 'Loading...';

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Total Spend:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Full Name:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Categories:',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text('Select a category'),
                      isExpanded: true,
                      items: filteredCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Total Spend:',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _totalSpendController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter amount',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF288F13),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
