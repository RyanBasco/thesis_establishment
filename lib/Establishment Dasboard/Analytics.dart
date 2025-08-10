import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:thesis_establishment/Establishment%20Profile/EstabProfile.dart';

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
  int _selectedIndex = 0; // For bottom navigation bar

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
      fetchEstablishmentDocId(); // Fetch establishment doc ID
    }
  }

  Future<void> fetchEstablishmentDocId() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('establishments');
    DatabaseEvent establishmentEvent =
        await dbRef.orderByChild('email').equalTo(userEmail).once();

    if (establishmentEvent.snapshot.exists) {
      var establishmentData =
          Map<String, dynamic>.from(establishmentEvent.snapshot.value as Map);
      var firstRecord = establishmentData
          .keys.first; // Get the first matching key as document ID

      setState(() {
        establishmentDocId = firstRecord;
      });
      fetchTotalSpendData(); // Fetch TotalSpend data based on establishment ID
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  int getWeekOfYear(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  Future<void> fetchTotalSpendData() async {
    if (establishmentDocId == null) return;

    DatabaseReference visitsRef = FirebaseDatabase.instance.ref('Visits');
    DatabaseEvent visitsEvent = await visitsRef.once();

    Map<String, double> spendByDate = {};
    DateTime now = DateTime.now();

    if (visitsEvent.snapshot.exists) {
      var visitsData =
          Map<String, dynamic>.from(visitsEvent.snapshot.value as Map);

      for (var entry in visitsData.entries) {
        var data = Map<String, dynamic>.from(entry.value);

        if (data['Establishment'] != null &&
            data['Establishment']['EstablishmentID'] == establishmentDocId) {
          double totalSpend = (data['TotalSpend'] ?? 0).toDouble();

          DateTime date;
          if (data['Date'] is String) {
            try {
              date = DateFormat('MM/dd/yyyy').parse(data['Date']);
            } catch (e) {
              try {
                date = DateFormat('yyyy-MM-dd').parse(data['Date']);
              } catch (e) {
                continue; // Skip invalid dates
              }
            }
          } else {
            continue; // Skip if date is not a string
          }

          // Filter based on selected time period
          bool includeData = false;
          String formattedDate = '';

          if (selectedOption == 'Yearly') {
            // Include data from all years
            formattedDate = DateFormat('yyyy').format(date);
            includeData = true;
          } else if (selectedOption == 'Monthly') {
            // Include all months from all years
            formattedDate = DateFormat('MMMM yyyy').format(date);
            includeData = true;
          } else if (selectedOption == 'Weekly') {
            // Include all weeks from all years
            int weekNumber = getWeekOfYear(date);
            formattedDate = 'Week $weekNumber, ${date.year}';
            includeData = true;
          } else if (selectedOption == 'Daily') {
            // Include data from current day only
            if (date.year == now.year &&
                date.month == now.month &&
                date.day == now.day) {
              formattedDate = DateFormat('MMMM dd, yyyy').format(date);
              includeData = true;
            }
          }

          if (includeData) {
            if (spendByDate.containsKey(formattedDate)) {
              spendByDate[formattedDate] =
                  spendByDate[formattedDate]! + totalSpend;
            } else {
              spendByDate[formattedDate] = totalSpend;
            }
          }
        }
      }
    }

    // Convert spendByDate map to a sorted list of ChartData
    List<ChartData> fetchedData = spendByDate.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    // Sort the data based on date
    fetchedData.sort((a, b) {
      DateTime dateA, dateB;
      try {
        if (selectedOption == 'Yearly') {
          dateA = DateFormat('yyyy').parse(a.xValue);
          dateB = DateFormat('yyyy').parse(b.xValue);
        } else if (selectedOption == 'Monthly') {
          dateA = DateFormat('MMMM yyyy').parse(a.xValue);
          dateB = DateFormat('MMMM yyyy').parse(b.xValue);
        } else if (selectedOption == 'Weekly') {
          final weekPattern = RegExp(r'Week (\d+), (\d{4})');
          final matchA = weekPattern.firstMatch(a.xValue);
          final matchB = weekPattern.firstMatch(b.xValue);

          if (matchA != null && matchB != null) {
            int weekA = int.parse(matchA.group(1)!);
            int yearA = int.parse(matchA.group(2)!);
            int weekB = int.parse(matchB.group(1)!);
            int yearB = int.parse(matchB.group(2)!);

            if (yearA != yearB) return yearA.compareTo(yearB);
            return weekA.compareTo(weekB);
          }
          return 0;
        } else {
          dateA = DateFormat('MMMM dd, yyyy').parse(a.xValue);
          dateB = DateFormat('MMMM dd, yyyy').parse(b.xValue);
        }
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      chartData = fetchedData;
      isLoading = false;
    });
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
                        child:
                            const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 95),
                    const Text(
                      'Sales',
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
                            ? const Center(
                                child: Text('No data available for this user'))
                            : SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <CartesianSeries>[
                                  ColumnSeries<ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) =>
                                        data.xValue,
                                    yValueMapper: (ChartData data, _) =>
                                        data.yValue,
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
          color: selectedOption == option
              ? const Color(0xFF288F13)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedOption == option
                ? const Color(0xFF288F13)
                : Colors.black,
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
