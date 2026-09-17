// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/widgets/page_header.dart';

class IncidentPage extends StatefulWidget {
  const IncidentPage({super.key});

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  String type = 'Sélectionner';
  XFile? photo;
  bool saving = false;

  final desc = TextEditingController();

  @override
  void dispose() {
    desc.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    final selected = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (mounted && selected != null) setState(() => photo = selected);
  }

  Future<void> sendIncident() async {
    final description = desc.text.trim();

    if (type == 'Sélectionner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner le type d’incident.'),
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez décrire l’incident.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => saving = true);
    try {
      String? photoUrl;
      if (photo != null) {
        final ref = FirebaseStorage.instance.ref(
          'incidents/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putData(
          await photo!.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoUrl = await ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('incidents').add({
        'userId': user.uid,
        'type': type,
        'description': description,
        'photoUrl': photoUrl,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        desc.clear();
        type = 'Sélectionner';
        photo = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signalement envoyé.')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d’envoyer le signalement : $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Signaler un incident'),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Type d’incident'),

                  const SizedBox(height: 6),

                  DropdownButtonFormField<String>(
                    initialValue: type,
                    items: const [
                      DropdownMenuItem(
                        value: 'Sélectionner',
                        child: Text('Sélectionner'),
                      ),
                      DropdownMenuItem(value: 'Retard', child: Text('Retard')),
                      DropdownMenuItem(
                        value: 'Accident',
                        child: Text('Accident'),
                      ),
                      DropdownMenuItem(
                        value: 'Absence',
                        child: Text('Absence'),
                      ),
                      DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        type = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  const Text('Description'),

                  const SizedBox(height: 6),

                  TextField(
                    controller: desc,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Décrire l’incident...',
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text('Joindre une photo (optionnel)'),

                  const SizedBox(height: 6),

                  OutlinedButton.icon(
                    onPressed: saving ? null : pickPhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      photo == null ? 'Prendre une photo' : 'Photo ajoutée',
                    ),
                  ),

                  const SizedBox(height: 18),

                  FilledButton(
                    onPressed: saving ? null : sendIncident,
                    child: saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Envoyer le signalement'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
