import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentLoginpage.dart';

class PendingEstablishmentPage extends StatefulWidget {
  @override
  _PendingEstablishmentPageState createState() => _PendingEstablishmentPageState();
}

class _PendingEstablishmentPageState extends State<PendingEstablishmentPage> {
  String establishmentName = 'Loading...'; // Default value while loading
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _barangays = [];
  String? _currentCityCode; // To store the current city code
  String? _currentBarangayCode; // To store the current barangay code
  String? _currentCityName; // To store the current city name
  String? _currentBarangayName; // To store the current barangay name
  List<Map<String, String>> _documents = []; // To store document names and sizes
  String? _errorMessage; // To store the error message
  bool _showError = false; // To flag whether to show the error message

  @override
  void initState() {
    super.initState();
    _loadCityAndBarangayData();
    _fetchEstablishmentData(); // Fetch establishment data
  }

  Future<void> _loadCityAndBarangayData() async {
    try {
      final String cityData = await rootBundle.loadString('assets/city.json');
      final String barangayData = await rootBundle.loadString('assets/barangay.json');
      
      // Decode the cities
      List<Map<String, dynamic>> allCities = List<Map<String, dynamic>>.from(
        jsonDecode(cityData) as List
      );

      // Decode the barangays
      List<Map<String, dynamic>> allBarangays = List<Map<String, dynamic>>.from(
        jsonDecode(barangayData) as List
      );

      setState(() {
        _cities = allCities;
        _barangays = allBarangays;
      });
    } catch (error) {
      print("An error occurred while loading cities and barangays: $error");
    }
  }

  Future<void> _fetchEstablishmentData() async {
    final String email = FirebaseAuth.instance.currentUser!.email!; // Get the logged-in user's email
    final snapshot = await FirebaseDatabase.instance
        .ref('pendingEstablishments')
        .orderByChild('email')
        .equalTo(email)
        .once();

    if (snapshot.snapshot.exists) {
      final establishmentData = snapshot.snapshot.children.first;

      // Fetch the required fields
      establishmentName = establishmentData.child('establishmentName').value as String? ?? 'Unknown Establishment';
      final barangayCode = establishmentData.child('barangay').value as String? ?? '';
      final cityCode = establishmentData.child('city').value as String? ?? '';
      _currentCityCode = cityCode;
      _currentBarangayCode = barangayCode;

      // Find the city name
      final city = _cities.firstWhere((c) => c['city_code'] == _currentCityCode, orElse: () => {'city_name': ''});
      _currentCityName = city['city_name'];

      // Find the barangay name
      final barangay = _barangays.firstWhere((b) => b['brgy_code'] == _currentBarangayCode, orElse: () => {'brgy_name': ''});
      _currentBarangayName = barangay['brgy_name'];

      // Fetch document details
      final documentUrls = establishmentData.child('document').value as List<dynamic>? ?? [];
      await _fetchDocumentDetails(documentUrls); // Fetch document details

      setState(() {}); // Update the UI
    }
  }

  Future<void> _fetchDocumentDetails(List<dynamic> documentUrls) async {
    List<Map<String, String>> documentDetails = [];

    for (var url in documentUrls) {
      final fileName = Uri.parse(url).pathSegments.last; // Extract file name from URL
      final uri = Uri.parse(url); // Convert the string URL to a Uri object
      final response = await http.head(uri); // Fetch metadata

      if (response.statusCode == 200) {
        final fileSize = response.headers['content-length']; // Get file size
        documentDetails.add({
          'name': fileName,
          'size': fileSize != null ? '${(int.parse(fileSize) / 1024).toStringAsFixed(2)} KB' : 'Unknown size',
        });
      }
    }

    setState(() {
      _documents = documentDetails; // Update state with document details
    });
  }

  @override
  Widget build(BuildContext context) {
    final String email = FirebaseAuth.instance.currentUser!.email!; // Get the logged-in user's email

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$establishmentName - Pending Registration', // Dynamic title
          style: TextStyle(fontSize: 20), // Reduced font size
        ),
      ),
      body: SingleChildScrollView( // Make the body scrollable
        child: FutureBuilder<DatabaseEvent>(
          future: FirebaseDatabase.instance
              .ref('pendingEstablishments')
              .orderByChild('email')
              .equalTo(email)
              .once(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Show loading indicator
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error fetching data'));
            }

            if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
              return Center(child: Text('No pending establishment found.'));
            }

            // Extract the data from the snapshot
            final establishmentData = snapshot.data!.snapshot.children.first;
            final status = establishmentData.child('status').value as String? ?? ''; // Fetch status

            // Check if there's an error to display
            if (_showError) { // Check if there's an error to display
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red), // Red X icon
                    SizedBox(height: 10),
                    Text(_errorMessage ?? 'An error occurred', style: TextStyle(color: Colors.red)),
                  ],
                ),
              );
            }

            // Display the city and barangay names in the UI
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 4,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Section
                  Column(
                    children: [
                      if (status == 'denied') // Show error message if denied
                          Center(
                              child: Column(
                                  children: [
                                      Icon(Icons.error, color: Colors.red), // Red X icon
                                      SizedBox(height: 10),
                                      Text(_errorMessage ?? 'An error occurred', style: TextStyle(color: Colors.red)),
                                  ],
                              ),
                          )
                      else if (snapshot.connectionState == ConnectionState.waiting) // Show loading circle if waiting
                          Center(
                              child: CircularProgressIndicator(), // Loading circle
                          )
                      else if (status == 'pending') // Show loading circle if status is pending
                          Center(
                              child: CircularProgressIndicator(), // Loading circle
                          ),
                      SizedBox(height: 10), // Space between the loading circle and status
                      Align( // Align the status text to the left
                        alignment: Alignment.centerLeft,
                        child: InfoSection(
                          label: 'Status:',
                          value: _showError ? 'Error' : (status == 'denied' ? 'Denied' : 'Pending Verification'),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _showError || status == 'denied'
                        ? 'Your registration for **$establishmentName** has been reviewed, and we regret to inform you that it has not been approved. If you have any questions or need further assistance, please feel free to reach out.'
                        : 'Your registration for **$establishmentName** is currently under review. You will receive an update once the verification process is complete.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  SizedBox(height: 20),

                  // Establishment Details
                  InfoSection(label: 'Establishment Name:', value: establishmentName),
                  InfoSection(label: 'Barangay:', value: _currentBarangayName ?? 'N/A'),
                  InfoSection(label: 'City:', value: _currentCityName ?? 'N/A'),
                  InfoSection(label: 'Contact:', value: establishmentData.child('contact').value as String? ?? ''),
                  InfoSection(label: 'Email:', value: email),
                  InfoSection(label: 'Tourism Type:', value: establishmentData.child('tourismType').value as String? ?? ''),
                  InfoSection(label: 'Subcategory:', value: establishmentData.child('subCategory').value as String? ?? ''),
                  InfoSection(label: 'Street Address:', value: establishmentData.child('streetAddress').value as String? ?? ''),

                  // Add Documents section with fetched details
                  InfoSection(
                    label: 'Documents added:',
                    value: _documents.isNotEmpty
                        ? _documents.map((doc) => '${doc['name']} (${doc['size']})').join(', ')
                        : 'No documents added yet',
                  ),
                  SizedBox(height: 20),

                  // Edit Button (only visible if status is denied)
                  if (status == 'denied') // Check if the status is denied
                      Center(
                          child: ElevatedButton(
                              onPressed: () async {
                                  final snapshot = await FirebaseDatabase.instance
                                      .ref('pendingEstablishments')
                                      .orderByChild('email')
                                      .equalTo(FirebaseAuth.instance.currentUser!.email!)
                                      .once();
                                  if (snapshot.snapshot.exists) {
                                      final establishmentData = snapshot.snapshot.children.first;
                                      _showEditDialog(context, establishmentData); // Pass establishmentData
                                  }
                              },
                              child: Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF007bff),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              ),
                          ),
                      ),
                  SizedBox(height: 20),

                  // Logout Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => logout(context),
                      child: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF007bff),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void logout(BuildContext context) {
    // Implement logout functionality here (redirect to login page or clear session)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EstablishmentLogin()), // Redirect to EstablishmentLogin page
    );
  }

  // Function to show the edit dialog
  void _showEditDialog(BuildContext context, DataSnapshot establishmentData) {
    final TextEditingController establishmentNameController = TextEditingController(text: establishmentName);
    final TextEditingController streetAddressController = TextEditingController(text: establishmentData.child('streetAddress').value as String? ?? '');
    final TextEditingController contactController = TextEditingController(text: establishmentData.child('contact').value as String? ?? '');
    final TextEditingController emailController = TextEditingController(text: FirebaseAuth.instance.currentUser!.email!);
    
    // Initialize tourism type variable
    String? selectedTourismType = establishmentData.child('tourismType').value as String? ?? '';
    String? selectedSubCategory = establishmentData.child('subCategory').value as String? ?? '';

    // Define subcategory options based on tourism type
    List<String> subCategoryOptions = [];
    if (selectedTourismType == 'primary') {
        subCategoryOptions = [
            'Accommodation Establishments',
            'Travel and Tour Services',
            'Tourist Transport Operators',
            'Meetings, Incentives, Conventions and Exhibitions (MICE)',
            'Adventure/ Sports and Ecotourism Facilities',
            'Tourism Frontliner',
        ];
    } else if (selectedTourismType == 'secondary') {
        subCategoryOptions = [
            'Tourism-related Enterprises',
            'Health and Wellness Services',
            'Tourism Frontliner',
        ];
    }

    // Ensure selectedSubCategory is valid
    if (!subCategoryOptions.contains(selectedSubCategory)) {
        selectedSubCategory = null; // Reset if the current value is not valid
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Edit Establishment Details'),
                content: SingleChildScrollView(
                    child: Column(
                        children: [
                            TextField(
                                controller: establishmentNameController,
                                decoration: InputDecoration(labelText: 'Establishment Name'),
                            ),
                            TextField(
                                controller: streetAddressController,
                                decoration: InputDecoration(labelText: 'Street Address'),
                            ),
                            TextField(
                                controller: contactController,
                                decoration: InputDecoration(labelText: 'Contact'),
                            ),
                            TextField(
                                controller: emailController,
                                decoration: InputDecoration(labelText: 'Email'),
                                readOnly: true, // Make email read-only
                            ),
                            // Dropdown for Tourism Type
                            DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: 'Tourism Type'),
                                value: selectedTourismType,
                                items: const [
                                    DropdownMenuItem(
                                        value: 'primary',
                                        child: Text('Primary'),
                                    ),
                                    DropdownMenuItem(
                                        value: 'secondary',
                                        child: Text('Secondary'),
                                    ),
                                ],
                                onChanged: (value) {
                                    setState(() {
                                        selectedTourismType = value; // Update selected tourism type
                                        selectedSubCategory = null; // Reset subcategory to blank when changing tourism type

                                        // Update subcategory options based on the selected tourism type
                                        if (selectedTourismType == 'primary') {
                                            subCategoryOptions = [
                                                'Accommodation Establishments',
                                                'Travel and Tour Services',
                                                'Tourist Transport Operators',
                                                'Meetings, Incentives, Conventions and Exhibitions (MICE)',
                                                'Adventure/ Sports and Ecotourism Facilities',
                                                'Tourism Frontliner',
                                            ];
                                        } else if (selectedTourismType == 'secondary') {
                                            subCategoryOptions = [
                                                'Tourism-related Enterprises',
                                                'Health and Wellness Services',
                                                'Tourism Frontliner',
                                            ];
                                        }
                                    });
                                },
                                validator: (value) => value == null ? 'Please select a tourism type' : null,
                            ),
                            // Dropdown for Subcategory wrapped in a Container to prevent overflow
                            Container(
                                width: double.infinity, // Set width to fill available space
                                child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(labelText: 'Subcategory'),
                                    value: selectedSubCategory, // This will be null when switching types
                                    items: subCategoryOptions.map((subCategory) {
                                        return DropdownMenuItem(
                                            value: subCategory,
                                            child: Text(subCategory),
                                        );
                                    }).toList(),
                                    onChanged: (value) {
                                        setState(() {
                                            selectedSubCategory = value; // Update selected subcategory
                                        });
                                    },
                                    validator: (value) => value == null ? 'Please select a subcategory' : null,
                                ),
                            ),
                        ],
                    ),
                ),
                actions: [
                    TextButton(
                        onPressed: () {
                            // Implement save functionality here
                            String newEstablishmentName = establishmentNameController.text;
                            String newStreetAddress = streetAddressController.text;
                            String newContact = contactController.text;
                            String newTourismType = selectedTourismType ?? '';
                            String newSubCategory = selectedSubCategory ?? '';

                            // Update the database with new values
                            _updateEstablishmentDetails(newEstablishmentName, newStreetAddress, newContact, newTourismType, newSubCategory);

                            Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Save'),
                    ),
                    TextButton(
                        onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog without saving
                        },
                        child: Text('Cancel'),
                    ),
                ],
            );
        },
    );
  }

  // Function to update establishment details in the database
  Future<void> _updateEstablishmentDetails(String newEstablishmentName, String newStreetAddress, String newContact, String newTourismType, String newSubCategory) async {
    final String email = FirebaseAuth.instance.currentUser!.email!; // Get the logged-in user's email
    final snapshot = await FirebaseDatabase.instance
        .ref('pendingEstablishments')
        .orderByChild('email')
        .equalTo(email)
        .once();

    if (snapshot.snapshot.exists) {
        final establishmentData = snapshot.snapshot.children.first;
        final establishmentRef = establishmentData.ref;

        // Update the establishment details
        await establishmentRef.update({
            'establishmentName': newEstablishmentName,
            'streetAddress': newStreetAddress,
            'contact': newContact,
            'tourismType': newTourismType,
            'subCategory': newSubCategory,
        });

        // Optionally, refresh the data or state
        _fetchEstablishmentData(); // Refresh the data after update
    }
  }
}

class InfoSection extends StatelessWidget {
  final String label;
  final String value;

  InfoSection({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}