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
  String? fullName;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> categoryInputs = []; // Contains categories with checkbox and controller

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchEstablishmentServices();
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

  // Fetch establishment's selected services
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
          categoryInputs = services.map((service) {
            return {
              'category': service,
              'controller': TextEditingController(),
              'selected': false, // Checkbox state
            };
          }).toList();
        });
      } else {
        print("Establishment not found for this user.");
      }
    } else {
      print("No authenticated user found.");
    }
  }

  // Save data to Firebase
  // Save data to Firebase
Future<void> saveData() async {
  final userEmail = _auth.currentUser?.email;
  if (userEmail != null) {
    if (categoryInputs.isNotEmpty && fullName != null) {
      setState(() {
        isLoading = true;
      });

      final now = DateTime.now();
      String documentID = widget.scannedCode.trim();
      DatabaseReference visitsRef = FirebaseDatabase.instance.ref('Visits');
      DatabaseReference establishmentRef = FirebaseDatabase.instance.ref('establishments');
      DataSnapshot establishmentSnapshot = await establishmentRef.orderByChild('email').equalTo(userEmail).get();

      if (establishmentSnapshot.exists) {
        // Fetch establishment details directly
        var establishmentData = Map<String, dynamic>.from(establishmentSnapshot.value as Map);
        String establishmentDocID = establishmentData.keys.first;
        var establishmentDetails = establishmentData[establishmentDocID]; // Full details of establishment

        for (var input in categoryInputs.where((item) => item['selected'])) {
          final category = input['category'];
          final totalSpend = double.tryParse(input['controller'].text.trim());

          if (totalSpend != null && totalSpend > 0) {
            await visitsRef.push().set({
              'TotalSpend': totalSpend,
              'Category': category,
              'Date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
              'Time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
              'User': {
                'UID': documentID,
                'fullName': fullName,
              },
              // Add establishment details directly here
              'Establishment': {
                'EstablishmentID': establishmentDocID,
                'email': establishmentDetails['email'],
                'establishmentName': establishmentDetails['establishmentName'],
                'barangay': establishmentDetails['barangay'],
                'city': establishmentDetails['city'],
                'contact': establishmentDetails['contact'],
                'tourismType': establishmentDetails['tourismType'],
              }
            });
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScanQR()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Establishment not found for this user.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category and enter the spend amount.')),
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
              margin: const EdgeInsets.symmetric(vertical: 20), // Adds spacing between white boxes
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
                  const SizedBox(height: 10),
                  Text(
                    'Full Name: $displayName',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Categories:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 5), // Reduced spacing
                  SizedBox(
                    height: 200, // Limit the height for better layout
                    child: ListView.builder(
                      itemCount: categoryInputs.length,
                      itemBuilder: (context, index) {
                        final input = categoryInputs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0), // Adds spacing between rows
                          child: Row(
                            children: [
                              Checkbox(
                                value: input['selected'] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    input['selected'] = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(input['category']),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: input['controller'],
                                  keyboardType: TextInputType.number,
                                  enabled: input['selected'],
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '0',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
