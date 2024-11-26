import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thesis_establishment/Establishment%20Dasboard/Dashboard.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  int _selectedIndex = 1;
  String _establishmentName = '';
  String _tourismType = '';
  String _barangay = '';
  String _subCategory = '';
  String _email = '';
  String? _profileImageUrl;
  File? _profileImage;

  bool _isEditing = false;
  final TextEditingController _establishmentNameController = TextEditingController();
  final TextEditingController _tourismTypeController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Map<String, String> barangayMap = {};

  @override
  void initState() {
    super.initState();
    _loadBarangayData();
    _fetchEstablishmentData();
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

  Future<void> _loadBarangayData() async {
    final String response = await rootBundle.loadString('assets/barangay.json');
    final List<dynamic> data = json.decode(response);
    barangayMap = {for (var item in data) item['brgy_code']: item['brgy_name']};
  }

  Future<void> _fetchEstablishmentData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments');
        DatabaseEvent event = await dbRef.orderByChild('email').equalTo(user.email).once();

        if (event.snapshot.exists) {
          var establishmentData = Map<String, dynamic>.from(event.snapshot.value as Map);
          var firstRecord = Map<String, dynamic>.from(establishmentData.values.first);
          _updateControllers(firstRecord);
        }

        // Fetch profile image URL directly from Firebase Storage
        String fileName = 'Establishment/${user.uid}/profile_image/latest_image.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        String downloadUrl = await ref.getDownloadURL();

        setState(() {
          _profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print('Failed to fetch establishment data: $e');
      }
    }
  }

  void _updateControllers(Map<String, dynamic> data) {
    setState(() {
      _establishmentName = data['establishmentName'] ?? '';
      _tourismType = data['tourismType'] ?? '';
      String barangayCode = data['barangay'] ?? '';
      _barangay = barangayMap[barangayCode] ?? 'Unknown Barangay';
      _subCategory = data['subCategory'] ?? '';
      _email = data['email'] ?? '';

      _establishmentNameController.text = _establishmentName;
      _tourismTypeController.text = _tourismType;
      _barangayController.text = _barangay;
      _subCategoryController.text = _subCategory;
      _emailController.text = _email;
    });
  }

  Future<void> _saveProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments/${user.uid}');
        await dbRef.update({
          'establishmentName': _establishmentNameController.text,
          'tourismType': _tourismTypeController.text,
          'barangay': _barangayController.text,
          'subCategory': _subCategoryController.text,
        });
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        print('Failed to update profile: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      await _uploadImageToFirebase(image);
    }
  }

  Future<void> _uploadImageToFirebase(XFile image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String fileName = 'Establishment/${user.uid}/profile_image/latest_image.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);

        // Upload the file
        await ref.putFile(File(image.path));

        // Refresh the profile image URL by fetching directly from Firebase Storage
        String downloadUrl = await ref.getDownloadURL();
        setState(() {
          _profileImageUrl = downloadUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        }
      } catch (error) {
        print('Failed to upload image: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image. Please try again.')),
          );
        }
      }
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
          padding: const EdgeInsets.all(22.0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 60),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(10.0),
                    height: 690,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 25,
                          left: 95,
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 55,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null),
                            child: _profileImage == null && _profileImageUrl == null
                                ? const Icon(Icons.person, color: Colors.white, size: 65)
                                : null,
                          ),
                        ),
                        Positioned(
                          top: 80,
                          left: 170,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          top: 140,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                labelText: 'Establishment Name',
                                controller: _establishmentNameController,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 20),
                              _isEditing
                                  ? DropdownButtonFormField<String>(
                                      value: _tourismType.isNotEmpty && ['primary', 'secondary'].contains(_tourismType)
                                          ? _tourismType
                                          : null,
                                      items: ['primary', 'secondary'].map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          )).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _tourismType = value ?? '';
                                          _tourismTypeController.text = _tourismType;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Tourism Type',
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF2C812A),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[300],
                                      ),
                                    )
                                  : _buildTextField(
                                      labelText: 'Tourism Type',
                                      controller: _tourismTypeController,
                                      enabled: false,
                                    ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                labelText: 'Barangay',
                                controller: _barangayController,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 20),
                              _isEditing
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 0),
                                      child: DropdownButtonFormField<String>(
                                        value: _subCategory.isNotEmpty &&
                                                [
                                                  'Accommodation Establishments',
                                                  'Travel and Tour Services',
                                                  'Tourist Transport Operators',
                                                  'Meetings, Incentives, Conventions and Exhibitions (MICE)',
                                                  'Adventure/ Sports and Ecotourism Facilities',
                                                  'Tourism Frontliner'
                                                ].contains(_subCategory)
                                            ? _subCategory
                                            : null,
                                        items: [
                                          'Accommodation Establishments',
                                          'Travel and Tour Services',
                                          'Tourist Transport Operators',
                                          'Meetings, Incentives, Conventions and Exhibitions (MICE)',
                                          'Adventure/ Sports and Ecotourism Facilities',
                                          'Tourism Frontliner'
                                        ].map((category) => DropdownMenuItem(
                                              value: category,
                                              child: Text(category, overflow: TextOverflow.ellipsis),
                                            )).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _subCategory = value ?? '';
                                            _subCategoryController.text = _subCategory;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Subcategory',
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Color(0xFF2C812A),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[300],
                                        ),
                                        isExpanded: true,
                                      ),
                                    )
                                  : _buildTextField(
                                      labelText: 'Subcategory',
                                      controller: _subCategoryController,
                                      enabled: false,
                                    ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                labelText: 'Email',
                                controller: _emailController,
                                enabled: false,
                              ),
                              const SizedBox(height: 20),
                              if (!_isEditing)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF288F13),
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  ),
                                ),
                              if (_isEditing)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = false;
                                          _updateControllers({
                                            'establishmentName': _establishmentName,
                                            'tourismType': _tourismType,
                                            'barangay': _barangay,
                                            'subCategory': _subCategory,
                                            'email': _email,
                                          });
                                        });
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: _saveProfile,
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF288F13),
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_3_outlined, color: Colors.black),
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFF288F13)),
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

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2C812A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
