import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Define the ChartData class
class ChartData {
  final String xValue; // Store formatted Date as a String
  final double yValue; // Store accumulated TotalSpend for the date

  ChartData(this.xValue, this.yValue);
}

class Analytics extends StatefulWidget {
  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  String selectedOption = 'Monthly';
  List<ChartData> chartData = [];
  bool isLoading = true;
  String? userEmail;
  String? establishmentDocId; // To store establishment document ID

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          userEmail = user.email;
        });
      }
      fetchEstablishmentDocId(); // Fetch establishment doc ID
    }
  }

  Future<void> fetchEstablishmentDocId() async {
    // Query to get the establishment document ID based on user's email
    QuerySnapshot establishmentSnapshot = await FirebaseFirestore.instance
        .collection('establishments')
        .where('email', isEqualTo: userEmail) // Filter by email
        .get();

    if (establishmentSnapshot.docs.isNotEmpty) {
      if (mounted) {
        setState(() {
          establishmentDocId = establishmentSnapshot.docs.first.id; // Get the first document ID
        });
      }
      fetchTotalSpendData(); // Fetch TotalSpend data based on establishment ID
    }
  }

  int getWeekOfYear(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  Future<void> fetchTotalSpendData() async {
    if (establishmentDocId == null) return;

    QuerySnapshot visitsSnapshot = await FirebaseFirestore.instance
        .collection('Visits')
        .get(); // Fetch all documents in Visits collection

    Map<String, double> spendByDate = {}; // Map to aggregate spend by date

    for (var doc in visitsSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Check if EstablishmentId matches the logged-in establishment's document ID
      if (data['EstablishmentID'] == establishmentDocId) {
        double totalSpend = (data['TotalSpend'] ?? 0).toDouble();


        DateTime date;
        if (data['Date'] is Timestamp) {
          Timestamp dateTimestamp = data['Date'];
          date = dateTimestamp.toDate();
        } else if (data['Date'] is String) {
          String dateString = data['Date'];
          try {
            date = DateFormat('yyyy-MM-dd').parse(dateString);
          } catch (e) {
            date = DateTime.now();
          }
        } else {
          date = DateTime.now();
        }

        String formattedDate;
        if (selectedOption == 'Yearly') {
          formattedDate = DateFormat('yyyy').format(date);
        } else if (selectedOption == 'Monthly') {
          formattedDate = DateFormat('MMMM yyyy').format(date);
        } else if (selectedOption == 'Weekly') {
          int weekNumber = getWeekOfYear(date);
          formattedDate = 'Week $weekNumber, ${date.year}';
        } else if (selectedOption == 'Daily') {
          if (date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year) {
            formattedDate = DateFormat('MMMM dd, yyyy').format(date);
          } else {
            continue; // Skip if the date is not today
          }
        } else {
          formattedDate = DateFormat('MMMM dd, yyyy').format(date);
        }

        // Accumulate TotalSpend by date
        if (spendByDate.containsKey(formattedDate)) {
          spendByDate[formattedDate] = spendByDate[formattedDate]! + totalSpend;
        } else {
          spendByDate[formattedDate] = totalSpend;
        }
      }
    }

    if (mounted) {
      // Convert the map data to ChartData format for the chart
      List<ChartData> fetchedData = spendByDate.entries
          .map((entry) => ChartData(entry.key, entry.value))
          .toList();

      setState(() {
        chartData = fetchedData;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up any resources like listeners here if necessary.
    super.dispose();
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 95),
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    'Total Sales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildOption('Yearly'),
                    _buildOption('Monthly'),
                    _buildOption('Weekly'),
                    _buildOption('Daily'),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : chartData.isEmpty
                            ? const Center(child: Text('No data available for this user'))
                            : SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <CartesianSeries>[
                                  ColumnSeries<ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.xValue,
                                    yValueMapper: (ChartData data, _) => data.yValue,
                                    color: const Color(0xFF288F13),
                                    width: 0.5,
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildOption(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
          fetchTotalSpendData(); // Refresh data based on selected filter
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: selectedOption == option ? const Color(0xFF288F13) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedOption == option ? const Color(0xFF288F13) : Colors.black,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: selectedOption == option ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
