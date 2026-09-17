import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/firebase_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final village = TextEditingController();
  final canton = TextEditingController();
  final subPrefecture = TextEditingController();
  final department = TextEditingController();

  String role = 'employe';
  String? imageUrl;
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseService().getUserProfile(user.uid);
    final data = snapshot.data() ?? {};
    if (!mounted) return;

    setState(() {
      name.text = data['name']?.toString() ?? user.displayName ?? '';
      phone.text = data['phone']?.toString() ?? '';
      village.text = data['village']?.toString() ?? '';
      canton.text = data['canton']?.toString() ?? '';
      subPrefecture.text = data['subPrefecture']?.toString() ?? '';
      department.text = data['department']?.toString() ?? '';
      role = data['role']?.toString() == 'agriculteur'
          ? 'agriculteur'
          : 'employe';
      imageUrl = data['photoUrl']?.toString();
      loading = false;
    });
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (mounted) {
      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final requiredFields = {
      'nom complet': name,
      'village': village,
      'canton': canton,
      'sous-préfecture': subPrefecture,
      'département': department,
    };
    for (final entry in requiredFields.entries) {
      if (entry.value.text.trim().isEmpty) {
        _showMessage('Le champ ${entry.key} est obligatoire.');
        return;
      }
    }

    setState(() => saving = true);
    try {
      String? savedImageUrl = imageUrl;
      if (selectedImage != null) {
        final path = 'profiles/${user.uid}/avatar.jpg';
        final ref = FirebaseStorage.instance.ref(path);
        await ref.putData(
          await selectedImage!.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        savedImageUrl = await ref.getDownloadURL();
      }

      await FirebaseService().saveUserProfile(user.uid, {
        'uid': user.uid,
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        'role': role,
        'type': role,
        'village': village.text.trim(),
        'canton': canton.text.trim(),
        'subPrefecture': subPrefecture.text.trim(),
        'department': department.text.trim(),
        'photoUrl': savedImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(name.text.trim());
      if (savedImageUrl != null) await user.updatePhotoURL(savedImageUrl);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (error) {
      _showMessage('Impossible d’enregistrer le profil : $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: saving ? null : _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: selectedImageBytes != null
                      ? MemoryImage(selectedImageBytes!)
                      : (imageUrl != null ? NetworkImage(imageUrl!) : null)
                            as ImageProvider?,
                  child: selectedImage == null && imageUrl == null
                      ? const Icon(Icons.add_a_photo_outlined, size: 32)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Ajouter une photo de profil')),
            const SizedBox(height: 22),
            _field(name, 'Nom complet', Icons.person_outline),
            const SizedBox(height: 12),
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
                DropdownMenuItem(value: 'employe', child: Text('Employé')),
              ],
              onChanged: saving
                  ? null
                  : (value) => setState(() => role = value ?? role),
            ),
            const SizedBox(height: 12),
            _field(
              phone,
              'Téléphone',
              Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            const Text(
              'Localisation agricole',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _field(village, 'Village', Icons.home_work_outlined),
            const SizedBox(height: 12),
            _field(canton, 'Canton', Icons.map_outlined),
            const SizedBox(height: 12),
            _field(
              subPrefecture,
              'Sous-préfecture',
              Icons.location_city_outlined,
            ),
            const SizedBox(height: 12),
            _field(department, 'Département', Icons.account_balance_outlined),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                saving ? 'Enregistrement...' : 'Enregistrer le profil',
              ),
            ),
          ],
        ),
      ),
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
