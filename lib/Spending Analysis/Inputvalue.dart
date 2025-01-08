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

  // Fetch user or group details
  void fetchUserData() async {
    String documentID = widget.scannedCode.trim();
    
    // First try to fetch from Groups
    DatabaseReference groupRef = FirebaseDatabase.instance.ref('Groups/$documentID');
    DatabaseEvent groupEvent = await groupRef.once();

    if (!mounted) return;

    if (groupEvent.snapshot.exists) {
      // It's a group QR code
      final groupData = Map<String, dynamic>.from(groupEvent.snapshot.value as Map);
      if (mounted) {
        setState(() {
          fullName = 'Group Name: ${groupData['groupName'] ?? 'Unknown Group'}';
        });
      }
    } else {
      // If not a group, try to fetch individual user
      DatabaseReference userRef = FirebaseDatabase.instance.ref('Users/$documentID');
      DatabaseEvent userEvent = await userRef.once();

      if (!mounted) return;

      if (userEvent.snapshot.exists) {
        final userData = Map<String, dynamic>.from(userEvent.snapshot.value as Map);
        setState(() {
          String firstName = userData['first_name'] ?? 'N/A';
          String lastName = userData['last_name'] ?? 'N/A';
          fullName = 'Full Name: $firstName $lastName';
        });
      } else {
        if (mounted) {
          setState(() {
            fullName = 'User/Group not found';
          });
        }
      }
    }
  }

  // Fetch establishment's selected services
  Future<void> fetchEstablishmentServices() async {
    final userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      DatabaseReference establishmentRef = FirebaseDatabase.instance.ref('establishments');
      DataSnapshot establishmentSnapshot = await establishmentRef.orderByChild('email').equalTo(userEmail).get();

      if (!mounted) return;

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
  Future<void> saveData() async {
    // Check if any category is selected and has a value
    bool hasSelectedCategory = false;
    bool hasValidInput = false;

    for (var input in categoryInputs) {
      if (input['selected']) {
        hasSelectedCategory = true;
        if (input['controller'].text.isNotEmpty && double.tryParse(input['controller'].text.trim()) != null) {
          hasValidInput = true;
          break;
        }
      }
    }

    if (!hasSelectedCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    if (!hasValidInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount for selected categories')),
      );
      return;
    }

    final userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      if (categoryInputs.isNotEmpty && fullName != null) {
        setState(() {
          isLoading = true;
        });

        final now = DateTime.now();
        String documentID = widget.scannedCode.trim();
        DatabaseReference visitsRef = FirebaseDatabase.instance.ref('Visits');
        DatabaseReference pendingReviewsRef = FirebaseDatabase.instance.ref('PendingReviews');
        DatabaseReference establishmentRef = FirebaseDatabase.instance.ref('establishments');
        
        // First check if this is a group
        DatabaseReference groupRef = FirebaseDatabase.instance.ref('Groups/$documentID');
        DatabaseEvent groupEvent = await groupRef.once();
        
        // Fetch establishment data
        DataSnapshot establishmentSnapshot = await establishmentRef.orderByChild('email').equalTo(userEmail).get();

        if (establishmentSnapshot.exists) {
          var establishmentData = Map<String, dynamic>.from(establishmentSnapshot.value as Map);
          String establishmentDocID = establishmentData.keys.first;
          var establishmentDetails = establishmentData[establishmentDocID];

          // Create a timestamp string
          String timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
          
          // Update date format to mm/dd/yyyy
          String formattedDate = '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
          
          // Get selected categories and their values
          List<Map<String, dynamic>> selectedCategories = categoryInputs
              .where((input) => input['selected'])
              .map((input) => {
                    'category': input['category'],
                    'amount': double.parse(input['controller'].text.trim())
                  })
              .toList();

          Map<String, dynamic> pendingReviewData = {
            'establishment_id': establishmentDocID,
            'timestamp': timestamp,
            'status': 'pending',
            'user_id': documentID,
            'categories': selectedCategories,  // Add the categories data
          };

          // Save to PendingReviews
          await pendingReviewsRef.push().set(pendingReviewData);

          // Continue with existing visit data saving
          for (var input in categoryInputs.where((item) => item['selected'])) {
            final category = input['category'];
            final totalSpend = double.tryParse(input['controller'].text.trim());

            if (totalSpend != null && totalSpend > 0) {
              Map<String, dynamic> visitData = {
                'TotalSpend': totalSpend,
                'Category': category,
                'Date': formattedDate,  // Use the new formatted date
                'Time': '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}',
                'Establishment': {
                  'EstablishmentID': establishmentDocID,
                  'email': establishmentDetails['email'],
                  'establishmentName': establishmentDetails['establishmentName'],
                  'barangay': establishmentDetails['barangay'],
                  'city': establishmentDetails['city'],
                  'contact': establishmentDetails['contact'],
                  'tourismType': establishmentDetails['tourismType'],
                }
              };

              // Add either Group or User data based on what was scanned
              if (groupEvent.snapshot.exists) {
                final groupData = Map<String, dynamic>.from(groupEvent.snapshot.value as Map);
                visitData['Groups'] = {
                  'GroupID': documentID,
                  ...groupData  // This will include all group data from Firebase
                };
              } else {
                // Fetch user data from Users and Forms
                DatabaseReference userRef = FirebaseDatabase.instance.ref('Users/$documentID');
                DatabaseReference formRef = FirebaseDatabase.instance.ref('Forms/$documentID');
                
                DatabaseEvent userEvent = await userRef.once();
                DatabaseEvent formEvent = await formRef.once();

                Map<String, dynamic> userData = {};
                
                if (userEvent.snapshot.exists) {
                  userData = Map<String, dynamic>.from(userEvent.snapshot.value as Map);
                }
                
                if (formEvent.snapshot.exists) {
                  final formData = Map<String, dynamic>.from(formEvent.snapshot.value as Map);
                  userData.addAll(formData); // Merge form data with user data
                }

                visitData['User'] = {
                  'UID': documentID,
                  ...userData  // Include all user and form data
                };
              }

              await visitsRef.push().set(visitData);
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data saved successfully!')),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ScanQR()),
            );
          }
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
                    displayName,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ScanQR()),
                );
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
