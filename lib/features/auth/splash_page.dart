// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/firebase_bootstrap.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/firebase_service.dart' as app_firebase;
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/bao_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    unawaited(
      FirebaseBootstrap.initialize().catchError((_) {
        // Le démarrage de l'application ne doit pas rester bloqué
        // si Firebase rencontre momentanément un problème.
      }),
    );

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = Firebase.apps.isNotEmpty
        ? FirebaseAuth.instance.currentUser
        : null;

    if (user != null) {
      try {
        await app_firebase.FirebaseService()
            .ensureDemoData(user.uid, name: user.displayName)
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // L'application peut continuer avec le cache Firestore hors ligne.
      }
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      user == null ? AppRoutes.login : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.beige,
                border: Border.all(color: AppTheme.orange, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.orange.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.eco, color: AppTheme.green, size: 56),
            ),

            const SizedBox(height: 18),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto',
                ),
                children: [
                  TextSpan(
                    text: 'Bâo',
                    style: TextStyle(color: AppTheme.green),
                  ),
                  TextSpan(
                    text: '-KOSS',
                    style: TextStyle(color: AppTheme.orange),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'La bonne compétence,\n'
              'au bon endroit, au bon moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 32),

            const SizedBox(
              width: 28,
              child: LinearProgressIndicator(
                minHeight: 6,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
