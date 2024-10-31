import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
      // Query to get the document ID based on user's email in Realtime Database
      DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments');
      DatabaseEvent event = await dbRef.orderByChild('email').equalTo(user.email).once();

      if (event.snapshot.exists) {
        var data = Map<String, dynamic>.from(event.snapshot.value as Map);
        userDocId = data.keys.first; // Get the first matching document ID
        fetchVisitRecords();
      }
    }
  }

  Future<void> fetchVisitRecords() async {
    if (userDocId == null) return;

    DatabaseReference visitsRef = FirebaseDatabase.instance.ref('Visits');
    DatabaseEvent visitsEvent = await visitsRef.orderByChild('EstablishmentID').equalTo(userDocId).once();

    DateFormat dateFormat1 = DateFormat('yyyy-MM-dd');
    DateFormat dateFormat2 = DateFormat('yyyy-M-d');

    List<Map<String, dynamic>> records = [];
    if (visitsEvent.snapshot.exists) {
      var visitsData = Map<String, dynamic>.from(visitsEvent.snapshot.value as Map);

      for (var entry in visitsData.entries) {
        var data = Map<String, dynamic>.from(entry.value);

        DateTime date;
        if (data['Date'] is String) {
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

        DatabaseReference userRef = FirebaseDatabase.instance.ref('Users/$uid');
        DatabaseEvent userEvent = await userRef.once();
        String firstName = 'Unknown';
        String lastName = 'Unknown';

        if (userEvent.snapshot.exists) {
          var userData = Map<String, dynamic>.from(userEvent.snapshot.value as Map);
          firstName = userData['first_name'] ?? 'Unknown';
          lastName = userData['last_name'] ?? 'Unknown';
        }

        String fullName = '$firstName $lastName';

        records.add({
          'Name': fullName,
          'Category': category,
          'Date': date,
          'TotalSpend': totalSpend,
        });
      }
    }

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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
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
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                color: Colors.white, // White background for the table
                                padding: const EdgeInsets.all(8.0),
                                child: Table(
                                  border: TableBorder.all(color: Colors.black54),
                                  columnWidths: const {
                                    0: FixedColumnWidth(150),
                                    1: FixedColumnWidth(120),
                                    2: FixedColumnWidth(100),
                                    3: FixedColumnWidth(100),
                                    4: FixedColumnWidth(100),
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
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Category',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Date',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Time',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Total Spend',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ...visitRecords.map(
                                      (record) => TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              record['Name'] ?? 'Unknown',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              record['Category'],
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              DateFormat('yyyy-MM-dd').format(record['Date']),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              DateFormat('hh:mm a').format(record['Date']),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '₱${record['TotalSpend'].toStringAsFixed(2)}',
                                              textAlign: TextAlign.center,
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
