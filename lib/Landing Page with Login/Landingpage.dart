import 'package:flutter/material.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentLoginpage.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Call the function to navigate after 5 seconds
    _navigateToNextPage();
  }

  // Function to navigate to the next page after 5 seconds
  void _navigateToNextPage() {
    Future.delayed (const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => EstablishmentLogin(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500), // Adjust animation duration
        ),
      );
    });
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
        child: Center(
          child: Image.asset(
            'assets/Islabiz.png',
            fit: BoxFit.contain, // Adjust the image fit
            width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
            height: MediaQuery.of(context).size.height * 0.8, // Adjust the height as needed
          ),
        ),
      ),
    );
  }
}
