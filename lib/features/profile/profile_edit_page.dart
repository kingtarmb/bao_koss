import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/firebase_service.dart';
import '../../shared/widgets/page_header.dart';

class ProfileEditPage extends StatefulWidget {
  final bool onboarding;

  const ProfileEditPage({super.key, this.onboarding = false});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final village = TextEditingController();
  final canton = TextEditingController();
  final subPrefecture = TextEditingController();
  final department = TextEditingController();

  String role = 'employe';
  bool loading = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    try {
      final snapshot = await FirebaseService().getUserProfile(user.uid);
      final data = snapshot.data() ?? {};
      name.text = data['name']?.toString() ?? user.displayName ?? '';
      phone.text = data['phone']?.toString() ?? '';
      village.text = data['village']?.toString() ?? '';
      canton.text = data['canton']?.toString() ?? '';
      subPrefecture.text = data['subPrefecture']?.toString() ?? '';
      department.text = data['department']?.toString() ?? '';
      final savedRole = data['role']?.toString();
      if (savedRole == 'agriculteur' || savedRole == 'employe') {
        role = savedRole!;
      }
    } catch (e) {
      error = 'Impossible de charger le profil : $e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final requiredFields = <String, String>{
      'nom complet': name.text.trim(),
      'village': village.text.trim(),
      'canton': canton.text.trim(),
      'sous-préfecture': subPrefecture.text.trim(),
      'département': department.text.trim(),
    };
    final missing = requiredFields.entries
        .where((entry) => entry.value.isEmpty)
        .map((entry) => entry.key)
        .join(', ');
    if (missing.isNotEmpty) {
      setState(() => error = 'Veuillez renseigner : $missing.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      await FirebaseService().saveUserProfile(user.uid, {
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        'role': role,
        'type': role,
        'village': village.text.trim(),
        'canton': canton.text.trim(),
        'subPrefecture': subPrefecture.text.trim(),
        'department': department.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(name.text.trim());

      if (!mounted) return;
      if (widget.onboarding) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Enregistrement impossible : $e');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      name,
      phone,
      village,
      canton,
      subPrefecture,
      department,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: widget.onboarding
                  ? 'Compléter mon profil'
                  : 'Modifier le profil',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  if (widget.onboarding)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Renseignez votre zone agricole pour accéder aux missions.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _field(name, 'Nom complet', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(
                    phone,
                    'Téléphone',
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Rôle',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'agriculteur',
                        child: Text('Agriculteur'),
                      ),
                      DropdownMenuItem(
                        value: 'employe',
                        child: Text('Employé'),
                      ),
                    ],
                    onChanged: saving
                        ? null
                        : (value) => setState(() => role = value ?? role),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Localisation agricole',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _field(village, 'Village', Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _field(canton, 'Canton', Icons.map_outlined),
                  const SizedBox(height: 12),
                  _field(
                    subPrefecture,
                    'Sous-préfecture',
                    Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 12),
                  _field(department, 'Département', Icons.domain_outlined),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: saving ? null : _save,
                      icon: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        widget.onboarding
                            ? 'Enregistrer et continuer'
                            : 'Enregistrer les modifications',
                      ),
                    ),
                  ),
                  if (!widget.onboarding)
                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.onboarding ? null : const SizedBox.shrink(),
      backgroundColor: const Color(0xFFF7F7F5),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: !saving,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
