import 'package:flutter/material.dart';

class Review extends StatefulWidget {
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  int _selectedIndex = 0; // Default selection for bottom navigation bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Increase height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: false, // Remove the default back arrow
          flexibleSpace: Container(
            decoration: const  BoxDecoration(
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
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0), // Adjust vertical padding
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(8.0), // Padding for the circle
                    child: const Icon(Icons.arrow_back, color: Colors.black), // Back arrow inside circle
                  ),
                ),
                const SizedBox(width: 95), // Space between icon and text
                const Text(
                  'Review',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ],
            ),
          ),
          actions: [], // Ensure no actions are present
        ),
      ),
      body: Container(
        color: Colors.white, // White background below the AppBar
        child: Stack(
          children: [
            // Row containing the rating and stars along with the boxes
            Positioned(
              top: 40, // Adjust top position for the row
              left: 20, // Set left position to align with the boxes
              child: Row(
                children: [
                  // Column for rating and stars
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     const Padding(
                        padding: const EdgeInsets.only(left: 30.0), // Add left padding to move 5.0 to the right
                        child: Text(
                          '5.0', // Rating text
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) => const Icon(
                          Icons.star,
                          color: Colors.yellow, // Yellow color for stars
                          size: 20.5,
                        )),
                      ),
                    ],
                  ),
                  SizedBox(width: 20), // Space between rating and the boxes
                  // First row: "All (0)" and "5 Star (0)"
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 120, // Set width for the white box
                            height: 40, // Set height for the white box
                            decoration: BoxDecoration(
                              color: Colors.white, // White background for the box
                              border: Border.all(color: Color(0xFF288F13), width: 2), // Green border
                            ),
                            child: const Center(
                              child: Text(
                                'All (0)', // Black text inside the white box
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(width: 15), // Space between the two boxes
                          Container(
                            width: 120, // Set width for the green box
                            height: 40, // Set height for the green box
                            decoration: BoxDecoration(
                              color: Color(0xFF288F13), // Green background for the box
                              border: Border.all(color: Color(0xFF288F13), width: 2), // Green border
                            ),
                            child: const Center(
                              child: Text(
                                '5 Star (0)', // White text inside the green box
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20), // Space between rows
                      // Second row: "4 Star (0)" and "3 Star (0)"
                      Row(
                        children: [
                          Container(
                            width: 120, // Set width for the green box
                            height: 40, // Set height for the green box
                            decoration: BoxDecoration(
                              color: Color(0xFF288F13), // Green background for the box
                              border: Border.all(color: const Color(0xFF288F13), width: 2), // Green border
                            ),
                            child: const Center(
                              child: Text(
                                '4 Star (0)', // White text inside the green box
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                         const SizedBox(width: 15), // Space between the two boxes
                          Container(
                            width: 120, // Set width for the green box
                            height: 40, // Set height for the green box
                            decoration: BoxDecoration(
                              color: Color(0xFF288F13), // Green background for the box
                              border: Border.all(color: Color(0xFF288F13), width: 2), // Green border
                            ),
                            child: const Center(
                              child: Text(
                                '3 Star (0)', // White text inside the green box
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20), // Space between rows
                      // Third row: "2 Star (0)" and "1 Star (0)"
                      Row(
                        children: [
                          Container(
                            width: 120, // Set width for the green box
                            height: 40, // Set height for the green box
                            decoration: BoxDecoration(
                              color: Color(0xFF288F13), // Green background for the box
                              border: Border.all(color: Color(0xFF288F13), width: 2), // Green border
                            ),
                            child: const Center(
                              child: Text(
                                '2 Star (0)', // White text inside the green box
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 15), // Space between the two boxes
                          Container(
                            width: 120, // Set width for the green box
                            height: 40, // Set height for the green box
                            decoration: BoxDecoration(
                              color: Color(0xFF288F13), // Green background for the box
                              border: Border.all(color: Color(0xFF288F13), width: 2), // Green border
                            ),
                            child: const Center(
                              child: Text(
                                '1 Star (0)', // White text inside the green box
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Grey line under the third row of boxes
            Positioned(
              top: 220, // Adjust the top position to place the line below the last row
              right: 0, // Align with the boxes
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0), // Padding to adjust position
                child: Container(
                  width: 455, // Width to match the total box width above
                  height: 2, // Thickness of the line
                  color: Colors.grey, // Grey color for the line
                ),
              ),
            ),
          ],
        ),
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
