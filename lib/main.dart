import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/EstablishmentLoginpage.dart';
import 'package:thesis_establishment/Landing%20Page%20with%20Login/Landingpage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    try {
      if (Platform.isAndroid) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCeSy9qMibAAYCZg5cipJ8097qeh3vwF08",
            appId: "1:920622301670:web:8937030299600fede51627",
            messagingSenderId: "920622301670",
            projectId: "testingapp-589a1",
            storageBucket: "testingapp-589a1.appspot.com",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 650), 
      minTextAdapt: true, 
      splitScreenMode: true, 
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: _handleAuthState(), 
        );
      },
    );
  }

    Widget _handleAuthState() {
    if (FirebaseAuth.instance.currentUser != null) {
      return EstablishmentLogin();
    } else {
      return LandingPage();
    }
  }
}

