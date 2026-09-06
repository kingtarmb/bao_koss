// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/firebase_bootstrap.dart';
import '../../core/routes/app_routes.dart';
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
    try {
      await FirebaseBootstrap.initialize();
    } catch (_) {
      // Le démarrage de l'application ne doit pas rester bloqué
      // si Firebase rencontre momentanément un problème.
    }

    await Future<void>.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacementNamed(
      context,
      user == null ? AppRoutes.login : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BaoLogo(size: 110),

            const SizedBox(height: 20),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: 'Bâo',
                    style: TextStyle(
                      color: AppTheme.green,
                    ),
                  ),
                  TextSpan(
                    text: '-KOSS',
                    style: TextStyle(
                      color: AppTheme.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'La bonne compétence,\n'
              'au bon endroit, au bon moment.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 35),

            const SizedBox(
              width: 26,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}