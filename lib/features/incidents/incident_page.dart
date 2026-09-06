// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';

import '../../shared/widgets/page_header.dart';

class IncidentPage extends StatefulWidget {
  const IncidentPage({super.key});

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  String type = 'Sélectionner';

  final desc = TextEditingController();

  @override
  void dispose() {
    desc.dispose();
    super.dispose();
  }

  void sendIncident() {
    final description = desc.text.trim();

    if (type == 'Sélectionner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner le type d’incident.',
          ),
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez décrire l’incident.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Signalement envoyé.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(
              title: 'Signaler un incident',
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Type d’incident',
                  ),

                  const SizedBox(height: 6),

                  DropdownButtonFormField<String>(
                    initialValue: type,
                    items: const [
                      DropdownMenuItem(
                        value: 'Sélectionner',
                        child: Text('Sélectionner'),
                      ),
                      DropdownMenuItem(
                        value: 'Retard',
                        child: Text('Retard'),
                      ),
                      DropdownMenuItem(
                        value: 'Accident',
                        child: Text('Accident'),
                      ),
                      DropdownMenuItem(
                        value: 'Absence',
                        child: Text('Absence'),
                      ),
                      DropdownMenuItem(
                        value: 'Autre',
                        child: Text('Autre'),
                      ),
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

                  const Text(
                    'Description',
                  ),

                  const SizedBox(height: 6),

                  TextField(
                    controller: desc,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Décrire l’incident...',
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Joindre une photo (optionnel)',
                  ),

                  const SizedBox(height: 6),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                    ),
                    label: const Text(
                      'Prendre une photo',
                    ),
                  ),

                  const SizedBox(height: 18),

                  FilledButton(
                    onPressed: sendIncident,
                    child: const Text(
                      'Envoyer le signalement',
                    ),
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