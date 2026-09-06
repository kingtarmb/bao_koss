// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool available = false;
  static bool initialized = false;

  static Future<void> initialize() async {
    if (initialized) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      available = true;
      initialized = true;

      // ignore: avoid_print
      print('🔥 Firebase initialisé avec succès.');
    } on FirebaseException catch (e) {
      available = false;

      // ignore: avoid_print
      print(
        '❌ FirebaseException lors de l’initialisation : '
        '${e.code} - ${e.message}',
      );
    } catch (e) {
      available = false;

      // ignore: avoid_print
      print('❌ Erreur Firebase : $e');
    }
  }
}