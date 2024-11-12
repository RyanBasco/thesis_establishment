import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:thesis_establishment/Records/Records.dart';

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
      DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments');
      DatabaseEvent event = await dbRef.orderByChild('email').equalTo(user.email).once();

      if (event.snapshot.exists) {
        var data = Map<String, dynamic>.from(event.snapshot.value as Map);
        userDocId = data.keys.first;
        fetchVisitRecords();
      }
    }
  }

  Future<void> fetchVisitRecords() async {
    if (userDocId == null) return;

    DatabaseReference visitsRef = FirebaseDatabase.instance.ref('Visits');
    DatabaseEvent visitsEvent = await visitsRef.once();

    List<Map<String, dynamic>> records = [];

    if (visitsEvent.snapshot.exists) {
      var visitsData = Map<String, dynamic>.from(visitsEvent.snapshot.value as Map);

      for (var entry in visitsData.entries) {
        var data = Map<String, dynamic>.from(entry.value);

        if (data['Establishment'] != null &&
            data['Establishment']['EstablishmentID'] == userDocId) {

          String category = data['Category'] ?? 'N/A';
          double totalSpend = (data['TotalSpend'] ?? 0).toDouble();
          String date = data['Date'] ?? 'Unknown'; // Separate Date field
          String time = data['Time'] ?? 'Unknown'; // Separate Time field

          String uid = data['User']?['UID'] ?? 'Unknown';
          String firstName = 'Unknown';
          String lastName = 'Unknown';

          if (uid != 'Unknown') {
            DatabaseReference userRef = FirebaseDatabase.instance.ref('Users/$uid');
            DatabaseEvent userEvent = await userRef.once();

            if (userEvent.snapshot.exists) {
              var userData = Map<String, dynamic>.from(userEvent.snapshot.value as Map);
              firstName = userData['first_name'] ?? 'Unknown';
              lastName = userData['last_name'] ?? 'Unknown';
            }
          }

          String fullName = '$firstName $lastName';

          records.add({
            'Name': fullName,
            'Category': category,
            'TotalSpend': totalSpend,
            'Date': date,   // Store Date separately
            'Time': time,   // Store Time separately
          });
        }
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Table(
                                border: TableBorder(
                                  horizontalInside: BorderSide(color: Colors.black12, width: 1),
                                  verticalInside: BorderSide(color: Colors.black12, width: 1),
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(1.5),
                                },
                                children: [
                                  // Header row
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade300,
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Category',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Total Spend',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Data rows with navigation on whole row tap
                                  ...visitRecords.asMap().entries.map(
                                    (entry) {
                                      int index = entry.key;
                                      Map<String, dynamic> record = entry.value;
                                      return TableRow(
                                        decoration: BoxDecoration(
                                          color: index.isEven ? Colors.grey[200] : Colors.white,
                                        ),
                                        children: [
                                          TableCell(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Records(
                                                      name: record['Name'],
                                                      category: record['Category'],
                                                      totalSpend: record['TotalSpend'],
                                                      date: record['Date'],
                                                      time: record['Time'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  record['Name'] ?? 'Unknown',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                record['Category'],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '₱${record['TotalSpend'].toStringAsFixed(2)}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
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
