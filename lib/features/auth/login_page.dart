// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/firebase_bootstrap.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/firebase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final identifier = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  String? error;
  bool phoneMode = true;

  String _emailFromPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return '${digits.replaceAll('+', '')}@bao-koss.local';
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (identifier.text.trim().isEmpty || password.text.isEmpty) {
      setState(() {
        error =
            'Veuillez renseigner votre téléphone/e-mail et votre mot de passe.';
      });
      return;
    }

    if (!FirebaseBootstrap.available) {
      setState(() {
        error =
            'Firebase n’est pas disponible. Lancez flutterfire configure puis vérifiez Internet.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final loginId = phoneMode
          ? _emailFromPhone(identifier.text)
          : identifier.text.trim();

      await FirebaseService().signInEmail(
        loginId,
        password.text,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = _firebaseMessage(e.code);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'Connexion impossible : $e';
      });
    }
  }

  String _firebaseMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Téléphone/e-mail ou mot de passe incorrect.';

      case 'invalid-email':
        return 'Identifiant invalide.';

      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';

      case 'network-request-failed':
        return 'Connexion Internet indisponible.';

      default:
        return 'Connexion impossible ($code).';
    }
  }

  Future<void> _resetPassword() async {
    final email = identifier.text.trim();

    if (email.isEmpty) {
      setState(() {
        error = 'Saisissez votre e-mail.';
      });
      return;
    }

    try {
      await FirebaseService().sendPasswordReset(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-mail de réinitialisation envoyé.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        error = _firebaseMessage(e.code);
      });
    }
  }

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const CircleAvatar(
                    radius: 42,
                    child: Icon(
                      Icons.person,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Connexion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 24),

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
                    onSelectionChanged: (values) {
                      setState(() {
                        phoneMode = values.first;
                        error = null;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: identifier,
                    keyboardType: phoneMode
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: phoneMode ? 'Téléphone' : 'E-mail',
                      prefixIcon: Icon(
                        phoneMode
                            ? Icons.phone
                            : Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                      ),
                    ),
                  ),

                  if (!phoneMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: loading ? null : _resetPassword,
                        child: const Text(
                          'Mot de passe oublié ?',
                        ),
                      ),
                    ),

                  if (error != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  FilledButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                          ),
                  ),

                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Text('ou'),
                      ),
                      Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            );
                          },
                    child: const Text(
                      "S'inscrire",
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'USSD : *XXX#',
                    textAlign: TextAlign.center,
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