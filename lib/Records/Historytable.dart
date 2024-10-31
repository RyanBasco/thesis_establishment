import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String? userDocId;
  List<Map<String, dynamic>> visitRecords = [];

  @override
  void initState() {
    super.initState();
    fetchUserDocumentId();
  }

  Future<void> fetchUserDocumentId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('establishments')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userDocId = snapshot.docs.first.id;
        });
        fetchVisitRecords();
      }
    }
  }

  Future<void> fetchVisitRecords() async {
  if (userDocId == null) return;

  QuerySnapshot visitsSnapshot = await FirebaseFirestore.instance
      .collection('Visits')
      .where('EstablishmentID', isEqualTo: userDocId)
      .get();

  DateFormat dateFormat1 = DateFormat('yyyy-MM-dd');
  DateFormat dateFormat2 = DateFormat('yyyy-M-d');

  List<Map<String, dynamic>> records = [];
  for (var doc in visitsSnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;

    DateTime date;
    if (data['Date'] is Timestamp) {
      date = (data['Date'] as Timestamp).toDate();
    } else if (data['Date'] is String) {
      try {
        date = dateFormat1.parse(data['Date']);
      } catch (e) {
        try {
          date = dateFormat2.parse(data['Date']);
        } catch (e) {
          date = DateTime.now();
        }
      }
    } else {
      date = DateTime.now();
    }

    String category = data['Category'] ?? 'N/A';
    double totalSpend = (data['TotalSpend'] ?? 0).toDouble();

    String uid = data['UID'];
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();

    String firstName = userDoc['first_name'] ?? 'Unknown';
    String lastName = userDoc['last_name'] ?? 'Unknown';
    String fullName = '$firstName $lastName';

    records.add({
      'Name': fullName,
      'Category': category,
      'Date': date,
      'TotalSpend': totalSpend,
    });
  }

  // Ensure widget is still mounted before calling setState
  if (mounted) {
    setState(() {
      visitRecords = records;
    });
  }
}


  @override
  Widget build(BuildContext context) {
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
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: visitRecords.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Container(
                              color: Colors.white, // White background for the table
                              child: Table(
                                border: TableBorder.all(color: Colors.black54),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(3),
                                  4: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Colors.black12,
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Category',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Date',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Time',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Total Spend',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...visitRecords.map(
                                    (record) => TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(record['Name'] ?? 'Unknown'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(record['Category']),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            DateFormat('yyyy-MM-dd')
                                                .format(record['Date']),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            DateFormat('hh:mm a')
                                                .format(record['Date']),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '₱${record['TotalSpend'].toStringAsFixed(2)}', // Changed to pesos
                                          ),
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          // Add navigation logic if needed
        },
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
}
