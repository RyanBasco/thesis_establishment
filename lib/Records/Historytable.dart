import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:thesis_establishment/Records/Records.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String? userDocId;
  List<Map<String, dynamic>> visitRecords = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserDocumentId();
  }

  Future<void> fetchUserDocumentId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments');
      DatabaseEvent event =
          await dbRef.orderByChild('email').equalTo(user.email).once();

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

    // Query with orderByChild to sort by date in descending order
    Query query = visitsRef.orderByChild('Date');

    try {
      DatabaseEvent visitsEvent = await query.once();
      List<Map<String, dynamic>> records = [];

      if (visitsEvent.snapshot.exists) {
        var visitsData =
            Map<String, dynamic>.from(visitsEvent.snapshot.value as Map);

        // Pre-fetch all user data to avoid multiple database calls
        Map<String, Map<String, dynamic>> userDataCache = {};
        Set<String> userIds = {};

        // First pass: collect all user IDs
        for (var entry in visitsData.entries) {
          var data = Map<String, dynamic>.from(entry.value);
          if (data['User'] != null && data['User']['UID'] != null) {
            userIds.add(data['User']['UID']);
          }
        }

        // Batch fetch user data
        if (userIds.isNotEmpty) {
          for (String uid in userIds) {
            DatabaseReference userRef =
                FirebaseDatabase.instance.ref('Users/$uid');
            DatabaseEvent userEvent = await userRef.once();
            if (userEvent.snapshot.exists) {
              userDataCache[uid] =
                  Map<String, dynamic>.from(userEvent.snapshot.value as Map);
            }
          }
        }

        // Process visits data using cached user information
        visitsData.forEach((key, value) {
          var data = Map<String, dynamic>.from(value);

          if (data['Establishment'] != null &&
              data['Establishment']['EstablishmentID'] == userDocId) {
            String category = data['Category'] ?? 'N/A';
            double totalSpend = (data['TotalSpend'] ?? 0).toDouble();
            String date = data['Date'] ?? 'Unknown';
            String time = data['Time'] ?? 'Unknown';
            String displayName = 'Unknown';

            // Check if it's a group visit
            if (data['Groups'] != null) {
              displayName = data['Groups']['groupName'] ?? 'Unknown Group';
            }
            // If not a group, use cached user data
            else if (data['User'] != null) {
              String uid = data['User']['UID'] ?? 'Unknown';
              if (userDataCache.containsKey(uid)) {
                var userData = userDataCache[uid]!;
                String firstName = userData['first_name'] ?? 'Unknown';
                String lastName = userData['last_name'] ?? 'Unknown';
                displayName = '$firstName $lastName';
              }
            }

            records.add({
              'Name': displayName,
              'Category': category,
              'TotalSpend': totalSpend,
              'Date': date,
              'Time': time,
            });
          }
        });

        // Sort records by date and time in descending order
        records.sort((a, b) {
          // Parse dates for proper comparison
          DateTime dateA = _parseDate(a['Date'].toString());
          DateTime dateB = _parseDate(b['Date'].toString());

          int dateComparison = dateB.compareTo(dateA);
          if (dateComparison != 0) {
            return dateComparison;
          }

          // Parse times for proper comparison
          return _compareTime(b['Time'].toString(), a['Time'].toString());
        });

        setState(() {
          visitRecords = records;
        });
      }
    } catch (e) {
      print('Error fetching visit records: $e');
    }
  }

  DateTime _parseDate(String date) {
    List<String> parts = date.split('/');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[0]), // month
        int.parse(parts[1]), // day
      );
    }
    return DateTime(1900); // fallback date for invalid format
  }

  int _compareTime(String time1, String time2) {
    List<String> parts1 = time1.split(' ');
    List<String> parts2 = time2.split(' ');

    if (parts1.length != 2 || parts2.length != 2) return 0;

    DateTime time1Parsed = _parseTime(parts1[0], parts1[1]);
    DateTime time2Parsed = _parseTime(parts2[0], parts2[1]);

    return time1Parsed.compareTo(time2Parsed);
  }

  DateTime _parseTime(String time, String period) {
    List<String> parts = time.split(':');
    if (parts.length != 2) return DateTime(2000);

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (period.toUpperCase() == 'PM' && hour != 12) {
      hour += 12;
    } else if (period.toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(2000, 1, 1, hour, minute);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EstablishmentProfile()),
      );
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
                      const SizedBox(width: 80),
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
                                  horizontalInside: BorderSide(
                                      color: Colors.black12, width: 1),
                                  verticalInside: BorderSide(
                                      color: Colors.black12, width: 1),
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
                                          'Name/Group Name',
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
                                          color: index.isEven
                                              ? Colors.grey[200]
                                              : Colors.white,
                                        ),
                                        children: [
                                          TableCell(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Records(
                                                      name: record['Name'],
                                                      category:
                                                          record['Category'],
                                                      totalSpend:
                                                          record['TotalSpend'],
                                                      date: record['Date'],
                                                      time: record['Time'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  record['Name'] ?? 'Unknown',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                record['Category'],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.groups_3_outlined,
              color: _selectedIndex == 0 ? Color(0xFF288F13) : Colors.black,
            ),
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 1 ? Color(0xFF288F13) : Colors.black,
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
