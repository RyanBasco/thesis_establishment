import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentLoginpage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterEstablishmentPage extends StatefulWidget {
  @override
  _RegisterEstablishmentPageState createState() => _RegisterEstablishmentPageState();
}

class _RegisterEstablishmentPageState extends State<RegisterEstablishmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  // Form fields
  String? _establishmentName;
  String? _tourismType;
  String? _subCategory;
  String? _city;
  String? _barangay;
  String? _contact;
  String? _email;
  String? _password;
  String? _streetAddress;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  List<PlatformFile> _selectedFiles = [];


  final Map<String, List<String>> _subCategoryOptions = {
    'primary': [
      'Accommodation Establishments',
      'Travel and Tour Services',
      'Tourist Transport Operators',
      'Meetings, Incentives, Conventions and Exhibitions (MICE)',
      'Adventure/ Sports and Ecotourism Facilities',
      'Tourism Frontliner'
    ],
    'secondary': [
      'Tourism-related Enterprises',
      'Health and Wellness Services',
      'Tourism Frontliner'
    ],
  };

  List<String> get _currentSubCategoryOptions =>
      _subCategoryOptions[_tourismType] ?? [];

  // Define the lists for cities and barangays
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _barangays = [];

  @override
  void initState() {
    super.initState();
    _loadCityAndBarangayData();
  }

  Future<void> _loadCityAndBarangayData() async {
    try {
      final String cityData = await rootBundle.loadString('assets/city.json');
      final String barangayData = await rootBundle.loadString('assets/barangay.json');
      
      // Decode only the cities with city_code starting with '0679'
      List<Map<String, dynamic>> guimarasCities = List<Map<String, dynamic>>.from(
        jsonDecode(cityData) as List
      ).where((city) => city['city_code'].startsWith('0679')).toList();

      // Store all barangays for later filtering
      List<Map<String, dynamic>> allBarangays = List<Map<String, dynamic>>.from(
        jsonDecode(barangayData) as List
      );

      setState(() {
        _cities = guimarasCities;
        _barangays = allBarangays;
      });
    } catch (error) {
      print("An error occurred while loading cities and barangays: $error");
    }
  }

  // Add this method to filter barangays based on selected city
  List<Map<String, dynamic>> _getFilteredBarangays() {
    if (_city == null) return [];
    return _barangays.where((barangay) => barangay['city_code'] == _city).toList();
  }

  Future<void> _registerEstablishment() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if files are selected
      if (_selectedFiles.isEmpty) {
        // Show error dialog if no files are uploaded
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please upload your Business Permit or related documents.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return; // Exit the method if no files are uploaded
      }
      setState(() {
        _isLoading = true;
      });
      
      try {
        _formKey.currentState?.save();
        
        // Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        // Store documents in Firebase Storage
        List<String> documentUrls = [];
        for (var file in _selectedFiles) {
          // Create a reference to the storage location with user ID
          final storageRef = FirebaseStorage.instance.ref().child('Documents/${userCredential.user?.uid}/${file.name}');
          // Upload the file
          await storageRef.putFile(File(file.path!));
          // Get the download URL
          String documentUrl = await storageRef.getDownloadURL();
          documentUrls.add(documentUrl);
        }

        // Format submission date
        String submissionDate = DateFormat('MM/dd/yy').format(DateTime.now());

        // Store the document URLs in Firebase Realtime Database
        await _db.child('pendingEstablishments/${userCredential.user?.uid}').set({
          'establishmentName': _establishmentName,
          'tourismType': _tourismType,
          'subCategory': _subCategory,
          'city': _city,
          'barangay': _barangay,
          'streetAddress': _streetAddress?.isEmpty == true ? 'N/A' : _streetAddress,
          'contact': '+63$_contact',
          'email': _email,
          'status': 'pending',
          'submissionDate': submissionDate,
          'document': documentUrls,
        });

        // Show success dialog
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration Pending'),
              content: Text('Your establishment registration has been submitted and is pending approval. You will be notified once your registration is approved.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstablishmentLogin(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );

      } catch (e) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        print("Error during registration: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showCitySearchDialog() async {
    final TextEditingController _searchController = TextEditingController();
    List<Map<String, dynamic>> filteredCities = _cities;

    final selectedCity = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select City"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {
                      filteredCities = _cities
                          .where((city) =>
                              city['city_name']
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Search City",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredCities[index]['city_name']),
                        onTap: () {
                          Navigator.pop(context, filteredCities[index]['city_code']);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        });
      },
    );

    if (selectedCity != null) {
      setState(() {
        _city = selectedCity;
        _barangay = null;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files.take(3).toList();
      });
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back on arrow click
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: Colors.black),
                      SizedBox(width: 8.0),
                      Text(
                        'Register Establishment',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFieldContainer(
                          icon: Icons.business,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Name of Establishment',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.white),
                            onSaved: (value) => _establishmentName = value,
                            validator: (value) => value?.isEmpty == true
                                ? 'Please enter the name of the establishment'
                                : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextFieldContainer(
                          icon: Icons.category,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Type',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            dropdownColor: Color(0xFF288F13),
                            iconEnabledColor: Colors.white,
                            style: TextStyle(color: Colors.white),
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
                                _tourismType = value;
                                _subCategory = null;
                              });
                            },
                            value: _tourismType,
                            validator: (value) => value == null
                                ? 'Please select a type of tourism enterprise'
                                : null,
                          ),
                        ),
                        if (_tourismType != null)
                          SizedBox(height: 20),
                        if (_tourismType != null)
                          _buildTextFieldContainer(
                            icon: Icons.subdirectory_arrow_right,
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Sub-Category',
                                labelStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              dropdownColor: Color(0xFF288F13),
                              iconEnabledColor: Colors.white,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                              items: _currentSubCategoryOptions
                                  .map((sub) => DropdownMenuItem(
                                        value: sub,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width - 125,
                                          child: Text(
                                            sub,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _subCategory = value),
                              value: _subCategory,
                              validator: (value) => value == null
                                  ? 'Please select a sub-category'
                                  : null,
                            ),
                          ),
                        SizedBox(height: 20),
                        // Searchable City Field
                        _buildTextFieldContainer(
                          icon: Icons.location_city,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'City',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            dropdownColor: Color(0xFF288F13),
                            iconEnabledColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            items: _cities.map((city) => DropdownMenuItem<String>(
                              value: city['city_code'].toString(),
                              child: Text(city['city_name'], overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (value) => setState(() {
                              _city = value;
                              _barangay = null; // Reset barangay when city changes
                            }),
                            value: _city,
                            validator: (value) => value == null ? 'Please select a city' : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextFieldContainer(
                          icon: Icons.location_on,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Barangay',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            dropdownColor: Color(0xFF288F13),
                            iconEnabledColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            items: _barangays
                                .where((barangay) => barangay['city_code'] == _city)
                                .map((barangay) => DropdownMenuItem<String>(
                                      value: barangay['brgy_code'].toString(),
                                      child: Text(barangay['brgy_name'],
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _barangay = value),
                            value: _barangay,
                            validator: (value) => value == null
                                ? 'Please select a barangay'
                                : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextFieldContainer(
                          icon: Icons.location_on,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Street Address',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.white),
                            onSaved: (value) => _streetAddress = value,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextFieldContainer(
                          icon: Icons.phone,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Contact No.',
                              prefixText: '+63 ',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            onSaved: (value) => _contact = value,
                            validator: (value) => RegExp(r'^9[0-9]{9}$')
                                .hasMatch(value ?? '')
                                ? null
                                : 'Please enter a valid contact number',
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextFieldContainer(
                          icon: Icons.email,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (value) => _email = value,
                            validator: (value) => value?.contains('@') == true
                                ? null
                                : 'Enter a valid email',
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextFieldContainer(
                          icon: Icons.lock,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            obscureText: !_isPasswordVisible,
                            onSaved: (value) => _password = value,
                            validator: (value) =>
                                (value != null && value.length >= 6)
                                    ? null
                                    : 'Password must be at least 6 characters long',
                          ),
                        ),
                        SizedBox(height: 20),
                        // File upload field
                        _buildTextFieldContainer(
                          icon: Icons.upload_file,
                          child: GestureDetector(
                            onTap: _pickFiles,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                _selectedFiles.isNotEmpty
                                    ? _selectedFiles.map((file) => file.name).join(', ')
                                    : 'Upload Business Permit or Related Documents (up to 3)',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF288F13),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registerEstablishment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Register',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldContainer({required Widget child, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFF288F13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}
