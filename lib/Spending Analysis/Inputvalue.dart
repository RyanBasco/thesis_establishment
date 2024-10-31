import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Inputvalue extends StatefulWidget {
  final String scannedCode; // The scanned QR code

  const Inputvalue({Key? key, required this.scannedCode}) : super(key: key);

  @override
  _InputvalueState createState() => _InputvalueState();
}

class _InputvalueState extends State<Inputvalue> {
  final TextEditingController _totalSpendController = TextEditingController();
  
  String? fullName; // To store the full name
  String? selectedCategory; // To store the selected category
  bool isLoading = false; // To control the loading state for the save button

  // List of categories
  final List<String> categories = [
    'Accommodation',
    'Food and Beverages',
    'Transportation',
    'Attractions and Activities',
    'Shopping',
    'Entertainment',
    'Wellness and Spa Services',
    'Adventure and Outdoor Activities',
    'Travel Insurance',
    'Local Tours and Guides',
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data based on the document ID from scanned code
  }

  void fetchUserData() async {
    String documentID = widget.scannedCode.trim(); // Assuming scannedCode is the document ID
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(documentID).get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        // Fetch first and last name
        String firstName = userData['first_name'] ?? 'N/A';
        String lastName = userData['last_name'] ?? 'N/A';
        fullName = '$firstName $lastName'; // Combine first and last name
      });
    } else {
      setState(() {
        fullName = 'User not found';
      });
    }
  }

  Future<void> saveData() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      final totalSpend = _totalSpendController.text.trim();
      if (totalSpend.isNotEmpty && fullName != null) {
        setState(() {
          isLoading = true; // Start loading
        });

        final now = DateTime.now();

        // Use the scanned code directly as the UID
        String documentID = widget.scannedCode.trim();

        // Query to find the establishment associated with the user's email
        var establishmentQuery = await FirebaseFirestore.instance
            .collection('establishments')
            .where('email', isEqualTo: userEmail)
            .get();

        if (establishmentQuery.docs.isNotEmpty) {
          // Assuming we want to take the first matching establishment
          String establishmentDocID = establishmentQuery.docs.first.id;

          await FirebaseFirestore.instance.collection('Visits').add({
            'UID': documentID, // Store the scanned code as UID
            'EstablishmentID': establishmentDocID, // Save the establishment document ID
            'TotalSpend': double.tryParse(totalSpend), // Ensure numeric values
            'Category': selectedCategory, // Store the selected category
            'Date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}', // Standard date format
            'Time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}', // Standard time format
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data saved successfully!')),
          );

          // Clear the input field after saving
          _totalSpendController.clear();

          // Navigate back to the previous page
          Navigator.pop(context);
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
      isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use full name to display
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
                    'Full Name:', // Label for Full Name
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName, // Display the full name
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 20),

                  // Categories Section
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
                      items: categories.map((String category) {
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
                      onPressed: isLoading ? null : saveData, // Disable button if loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF288F13),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
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
                Navigator.pop(context); // Navigate back on tap
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
