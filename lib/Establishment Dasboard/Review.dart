import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Review extends StatefulWidget {
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance; 
  String? loggedInDocumentId; 

  int _selectedIndex = 0;
  int? _selectedRatingFilter;
  Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _getLoggedInDocumentId(); 
  }

  Future<void> _getLoggedInDocumentId() async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      final snapshot = await _databaseRef.child('establishments/$userId').get();
      if (snapshot.exists) {
        setState(() {
          loggedInDocumentId = snapshot.key; 
        });
        _fetchReviews(); 
      } else {
        print("Establishment document not found for user ID: $userId");
      }
    } else {
      print("No user is logged in");
    }
  }

  void _fetchReviews() async {
    if (loggedInDocumentId == null) return;

    final snapshot = await _databaseRef.child('reviews').get();

    if (snapshot.exists) {
      Map data = snapshot.value as Map;

      setState(() {
        starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        reviews = [];

        data.forEach((key, value) {
          final review = Map<String, dynamic>.from(value);
          if (review['establishment_id'] == loggedInDocumentId) {
            if (review['categoryRatings'] != null) {
              Map<String, dynamic> categoryRatings = Map<String, dynamic>.from(review['categoryRatings'] as Map);
              Map<String, dynamic>? categoryComments = review['categoryComments'] != null 
                  ? Map<String, dynamic>.from(review['categoryComments'] as Map) 
                  : null;

              categoryRatings.forEach((category, rating) {
                int ratingValue = rating is int ? rating : (rating as num).toInt();
                
                if (ratingValue >= 1 && ratingValue <= 5) {
                  String firstName = review['first_name'] ?? '';
                  String lastName = review['last_name'] ?? '';
                  String comment = categoryComments != null ? categoryComments[category] ?? '' : '';
                  int timestamp = review['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
                  bool isHelpful = review['isHelpful'] ?? false;

                  reviews.add({
                    'rating': ratingValue,
                    'category': category,
                    'firstName': firstName,
                    'lastName': lastName,
                    'comment': comment,
                    'timestamp': timestamp,
                    'isHelpful': isHelpful,
                    'reviewKey': key,
                  });

                  if (starCounts.containsKey(ratingValue)) {
                    starCounts[ratingValue] = starCounts[ratingValue]! + 1;
                  }
                }
              });
            }
          }
        });
      });
    }
  }

  void _toggleHelpful(String reviewKey, bool isHelpful) async {
    await _databaseRef.child('reviews/$reviewKey').update({'isHelpful': !isHelpful});
    _fetchReviews(); 
  }

 
  void _filterReviewsByRating(int? rating) {
    setState(() {
      _selectedRatingFilter = rating;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEEFFA9), Color(0xFFDBFF4C), Color(0xFF51F643)],
                stops: [0.15, 0.54, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 95),
                const Text(
                  'Review',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummarySection(),
            const Divider(color: Colors.grey, height: 40, thickness: 1),
            _buildReviewList(),
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


Widget _buildSummarySection() {
  int totalRatings = starCounts.values.reduce((a, b) => a + b);
  double averageRating = totalRatings > 0
      ? (starCounts.entries.fold(0, (sum, entry) => sum + entry.key * entry.value) / totalRatings)
      : 0.0;

  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            Row(
              children: List.generate(5, (index) {
                double starValue = index + 1.0;
                if (starValue <= averageRating) {
                  return const Icon(Icons.star, color: Colors.yellow, size: 20.5);
                } else if (starValue - averageRating < 1 && starValue - averageRating > 0) {
                  return const Icon(Icons.star_half, color: Colors.yellow, size: 20.5);
                } else {
                  return const Icon(Icons.star_border, color: Colors.grey, size: 20.5);
                }
              }),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            _buildStarCountRow('All', totalRatings, null),
            _buildStarCountRow('5 Star', starCounts[5]!, 5),
            _buildStarCountRow('4 Star', starCounts[4]!, 4),
            _buildStarCountRow('3 Star', starCounts[3]!, 3),
            _buildStarCountRow('2 Star', starCounts[2]!, 2),
            _buildStarCountRow('1 Star', starCounts[1]!, 1),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildStarCountRow(String label, int count, int? ratingFilter) {
    bool isSelected = _selectedRatingFilter == ratingFilter;
    return GestureDetector(
      onTap: () => _filterReviewsByRating(ratingFilter),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        width: 140,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF288F13) : Colors.white,
          border: Border.all(color: Color(0xFF288F13), width: 2),
        ),
        child: Center(
          child: Text(
            '$label ($count)',
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  
  Widget _buildReviewList() {
    List<Map<String, dynamic>> filteredReviews = _selectedRatingFilter == null
        ? reviews
        : reviews.where((review) => review['rating'] == _selectedRatingFilter).toList();

    return Column(
      children: filteredReviews.map((review) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(review['timestamp']);
        String formattedDate = DateFormat.yMMMd().add_jm().format(date);
        bool isHelpful = review['isHelpful'] ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                Text(
                  '${review['firstName']} ${review['lastName']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
              
                Text(
                  'Category: ${review['category']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
               
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < review['rating'] ? Colors.yellow : Colors.grey,
                      size: 20,
                    );
                  }),
                ),
              
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
           
                Text(
                  review['comment'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
        
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _toggleHelpful(review['reviewKey'], isHelpful),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thumb_up,
                          color: isHelpful ? Color(0xFF288F13) : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Helpful',
                          style: TextStyle(
                            color: isHelpful ? Color(0xFF288F13) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
