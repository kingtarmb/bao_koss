// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/firebase_bootstrap.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/firebase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final identifier = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool phoneMode = true;
  bool loading = false;
  String? error;

  String _emailFromPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    return '$digits@bao-koss.local';
  }

  String _firebaseMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Ce numéro ou cette adresse e-mail possède déjà un compte.';
      case 'invalid-email':
        return 'Le numéro ou l’adresse e-mail n’est pas valide.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      case 'network-request-failed':
        return 'Connexion Internet impossible. Vérifiez votre connexion.';
      case 'operation-not-allowed':
        return 'La méthode de connexion n’est pas activée dans Firebase.';
      default:
        return 'Inscription impossible ($code).';
    }
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    final fullName = name.text.trim();
    final value = identifier.text.trim();
    final pwd = password.text;
    final confirmation = confirm.text;

    if (fullName.isEmpty) {
      setState(() {
        error = 'Veuillez renseigner votre nom complet.';
      });
      return;
    }

    if (value.isEmpty) {
      setState(() {
        error = phoneMode
            ? 'Veuillez renseigner votre numéro de téléphone.'
            : 'Veuillez renseigner votre adresse e-mail.';
      });
      return;
    }

    if (pwd.length < 6) {
      setState(() {
        error = 'Le mot de passe doit contenir au moins 6 caractères.';
      });
      return;
    }

    if (pwd != confirmation) {
      setState(() {
        error = 'Les deux mots de passe ne correspondent pas.';
      });
      return;
    }

    if (!FirebaseBootstrap.available) {
      setState(() {
        error =
            'Le service Firebase est momentanément indisponible. Veuillez réessayer.';
      });
      return;
    }

    // ------------------------------------------------------------
    // DÉBUT DU CHARGEMENT
    // ------------------------------------------------------------

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final email = phoneMode
          ? _emailFromPhone(value)
          : value.toLowerCase();

      debugPrint('BÂO-KOSS : création du compte...');
      debugPrint('Identifiant Firebase : $email');

      // ----------------------------------------------------------
      // 1. CRÉATION DU COMPTE FIREBASE AUTH
      // ----------------------------------------------------------

      final credential = await FirebaseService()
          .registerEmail(email, pwd)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw TimeoutException(
                'Le serveur Firebase met trop de temps à répondre.',
              );
            },
          );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Firebase n’a pas retourné l’utilisateur après l’inscription.',
        );
      }

      debugPrint('BÂO-KOSS : compte Firebase créé : ${user.uid}');

      // ----------------------------------------------------------
      // 2. CRÉATION DU PROFIL FIRESTORE
      // ----------------------------------------------------------

      try {
        await FirebaseService()
            .saveUserProfile(user.uid, {
              'uid': user.uid,
              'name': fullName,
              'identifier': value,
              'phone': phoneMode ? value : null,
              'email': phoneMode ? null : value.toLowerCase(),
              'type': 'ouvrier',
              'role': 'ouvrier',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            })
            .timeout(
              const Duration(seconds: 15),
            );

        debugPrint('BÂO-KOSS : profil Firestore créé.');
      } on TimeoutException {
        debugPrint(
          'BÂO-KOSS : délai Firestore dépassé. Le compte Auth existe.',
        );
      } on FirebaseException catch (e) {
        debugPrint(
          'BÂO-KOSS : erreur Firestore ${e.code}: ${e.message}',
        );

        // Le compte Firebase existe déjà.
        // On ne bloque donc pas l'utilisateur indéfiniment.
      }

      if (!mounted) return;

      // ----------------------------------------------------------
      // 3. FIN DU CHARGEMENT
      // ----------------------------------------------------------

      setState(() {
        loading = false;
      });

      // ----------------------------------------------------------
      // 4. DÉCONNEXION APRÈS INSCRIPTION
      //
      // Firebase connecte automatiquement l'utilisateur après
      // createUserWithEmailAndPassword().
      //
      // Nous voulons ici :
      //
      // INSCRIPTION → CONNEXION → ACCUEIL
      // ----------------------------------------------------------

      await FirebaseService().signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé avec succès. Vous pouvez maintenant vous connecter.',
          ),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = _firebaseMessage(e.code);
      });
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'Le serveur met trop de temps à répondre. Vérifiez votre connexion Internet puis réessayez.';
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.message ?? 'Une erreur Firebase est survenue.';
      });
    } catch (e) {
      debugPrint('BÂO-KOSS : erreur inscription : $e');

      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'Une erreur est survenue pendant l’inscription. Veuillez réessayer.';
      });
    } finally {
      // Sécurité supplémentaire :
      // le bouton ne doit JAMAIS rester bloqué.
      if (mounted && loading) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    identifier.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  const Text(
                    'Inscription',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const LinearProgressIndicator(
                    value: .33,
                    minHeight: 5,
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: name,
                    enabled: !loading,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Téléphone'),
                        icon: Icon(Icons.phone),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('E-mail'),
                        icon: Icon(Icons.email_outlined),
                      ),
                    ],
                    selected: {phoneMode},
                    onSelectionChanged: loading
                        ? null
                        : (values) {
                            setState(() {
                              phoneMode = values.first;
                              identifier.clear();
                              error = null;
                            });
                          },
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: identifier,
                    enabled: !loading,
                    keyboardType: phoneMode
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText:
                          phoneMode ? 'Téléphone' : 'E-mail',
                      prefixIcon: Icon(
                        phoneMode
                            ? Icons.phone
                            : Icons.email_outlined,
                      ),
                      hintText: phoneMode
                          ? 'Ex. 90120278'
                          : 'Ex. nom@email.com',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: password,
                    enabled: !loading,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: confirm,
                    enabled: !loading,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: loading ? null : register,
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Suivant',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                    child: const Text(
                      'J’ai déjà un compte',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}