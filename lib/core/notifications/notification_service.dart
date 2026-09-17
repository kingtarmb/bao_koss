// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_bootstrap.dart';

/// Initialise la réception des notifications push (Firebase Cloud
/// Messaging) : demande la permission puis récupère le token de
/// l'appareil. N'est appelée que si Firebase a pu s'initialiser.
class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (!FirebaseBootstrap.available) return;
    try {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.getToken();
    } catch (_) {
      // La demande de permission peut échouer (refusée par l'utilisateur,
      // plateforme non supportée...) sans bloquer le reste de l'application.
    }
  }
}
