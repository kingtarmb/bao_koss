// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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

      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (_) {}

      available = true;
      initialized = true;

      debugPrint('🔥 Firebase initialisé avec succès (persistance hors-ligne active).');
    } on FirebaseException catch (e) {
      available = false;
      debugPrint('❌ FirebaseException lors de l’initialisation : ${e.code} - ${e.message}');
    } catch (e) {
      available = false;
      debugPrint('❌ Erreur Firebase : $e');
    }
  }
}
