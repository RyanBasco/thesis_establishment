// establishment_app/lib/services/QRCodeHandler.dart

import 'package:firebase_database/firebase_database.dart';

class QRCodeHandler {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<void> handleQRCodeScan(String userId) async {
    await _databaseRef.child('scans/$userId').set({
      'status': 'pending',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Trigger FCM notification to user here (handled by Firebase Functions)
  }
}
