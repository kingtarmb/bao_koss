// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/firebase_service.dart';
import '../../shared/widgets/bottom_nav.dart';

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vous devez être connecté pour accéder aux missions.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes missions'),
        actions: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: service.userProfile(uid),
            builder: (context, snapshot) {
              final role = snapshot.data?.data()?['role']?.toString();
              if (role != 'agriculteur' && role != 'admin') {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Créer une mission',
                onPressed: () => _newMission(context),
                icon: const Icon(Icons.add),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.missions
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Impossible de charger les missions.\n\n'
                  '${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snap.hasData) {
            return const Center(
              child: Text('Aucune donnée disponible.'),
            );
          }

          final docs = snap.data!.docs.where((doc) {
            final data = doc.data();

            final farmerId = data['farmerId'] as String?;
            final workerId = data['workerId'] as String?;
            final status = data['status'] as String?;

            return farmerId == uid ||
                workerId == uid ||
                status == 'published';
          }).toList();

          final upcoming = docs.where((doc) {
            final data = doc.data();
            final status = data['status']?.toString() ?? 'published';
            return status == 'published' ||
                (data['workerId']?.toString() == uid && status == 'accepted');
          }).toList();
          final active = docs.where((doc) {
            final data = doc.data();
            return data['workerId']?.toString() == uid && data['status'] == 'in_progress';
          }).toList();
          final completed = docs.where((doc) {
            final data = doc.data();
            return data['workerId']?.toString() == uid &&
                (data['status'] == 'completed' || data['status'] == 'validated');
          }).toList();

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const Material(
                  color: Colors.transparent,
                  child: TabBar(
                    tabs: [
                      Tab(text: 'À venir'),
                      Tab(text: 'En cours'),
                      Tab(text: 'Terminées'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _missionList(context, upcoming),
                      _missionList(context, active),
                      _missionList(context, completed),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BaoBottomNav(
        selectedIndex: 1,
      ),
    );
  }

  Widget _missionList(BuildContext context, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) {
      return const Center(
        child: Text('Aucune mission dans cette catégorie.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();
        final status = data['status']?.toString() ?? 'published';
        final date = data['date']?.toString() ?? 'Date non renseignée';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.missionDetail, arguments: doc.id),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.agriculture, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['title']?.toString() ?? 'Mission sans titre', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(data['location']?.toString() ?? 'Lieu non renseigné', style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text('$date • ${data['budget'] ?? 0} FCFA', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusChip(status: status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _newMission(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _NewMissionSheet(),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  String get label {
    switch (status) {
      case 'published':
        return 'Publiée';
      case 'accepted':
        return 'Acceptée';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'validated':
        return 'Validée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
    );
  }
}

class _NewMissionSheet extends StatefulWidget {
  const _NewMissionSheet();

  @override
  State<_NewMissionSheet> createState() => _NewMissionSheetState();
}

class _NewMissionSheetState extends State<_NewMissionSheet> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final place = TextEditingController();
  final budget = TextEditingController();
  final lat = TextEditingController();
  final lng = TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    for (final controller in [
      title,
      desc,
      place,
      budget,
      lat,
      lng,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> save() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showError('Vous devez être connecté.');
      return;
    }

    if (title.text.trim().isEmpty) {
      _showError('Le titre de la mission est obligatoire.');
      return;
    }

    if (place.text.trim().isEmpty) {
      _showError('Le lieu de la mission est obligatoire.');
      return;
    }

    final budgetValue = double.tryParse(
      budget.text.trim().replaceAll(',', '.'),
    );

    if (budget.text.trim().isNotEmpty && budgetValue == null) {
      _showError('Le budget doit être un nombre valide.');
      return;
    }

    double? latitude;
    double? longitude;

    if (lat.text.trim().isNotEmpty) {
      latitude = double.tryParse(
        lat.text.trim().replaceAll(',', '.'),
      );

      if (latitude == null || latitude < -90 || latitude > 90) {
        _showError('La latitude doit être comprise entre -90 et 90.');
        return;
      }
    }

    if (lng.text.trim().isNotEmpty) {
      longitude = double.tryParse(
        lng.text.trim().replaceAll(',', '.'),
      );

      if (longitude == null || longitude < -180 || longitude > 180) {
        _showError(
          'La longitude doit être comprise entre -180 et 180.',
        );
        return;
      }
    }

    setState(() {
      saving = true;
    });

    try {
      final data = <String, dynamic>{
        'title': title.text.trim(),
        'description': desc.text.trim(),
        'location': place.text.trim(),
        'budget': budgetValue ?? 0,
        'latitude': latitude,
        'longitude': longitude,

        // Date lisible par l'application.
        'date': DateTime.now().toIso8601String(),

        // IMPORTANT :
        // utilisé par MissionsPage pour orderBy().
        'createdAt': FieldValue.serverTimestamp(),

        // Mission disponible pour les ouvriers.
        'status': 'published',

        // Agriculteur ayant créé la mission.
        'farmerId': user.uid,

        // Aucun ouvrier n'est encore affecté.
        'workerId': null,
      };

      await FirebaseService().createMission(data);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission publiée avec succès.'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de publier la mission.\n$e',
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nouvelle mission',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nom de la mission *',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: desc,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: place,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Lieu / Village *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: budget,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Budget (FCFA)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),

            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Coordonnées GPS (optionnelles)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: lat,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: lng,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.publish),
                label: Text(
                  saving
                      ? 'Publication en cours...'
                      : 'Publier la mission',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}