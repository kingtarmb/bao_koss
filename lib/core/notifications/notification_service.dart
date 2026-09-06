// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.getToken();
  }
}
