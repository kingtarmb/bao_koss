// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/widgets/page_header.dart';

class MissionDetailPage extends StatelessWidget {
  const MissionDetailPage({super.key});

  Future<void> _acceptMission(
    BuildContext context,
    String missionId,
    Map<String, dynamic> mission,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour accepter une mission.'),
        ),
      );
      return;
    }

    final applicationRef = FirebaseFirestore.instance
        .collection('missionApplications')
        .doc('${missionId}_${user.uid}');

    try {
      final existing = await applicationRef.get();

      if (existing.exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous avez déjà accepté cette mission.'),
            ),
          );
        }
        return;
      }

      await applicationRef.set({
        'missionId': missionId,
        'workerId': user.uid,
        'workerEmail': user.email,
        'missionTitle': mission['title'] ?? 'Mission',
        'missionOwnerId': mission['ownerId'],
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission acceptée avec succès.'),
        ),
      );

      Navigator.pushNamed(
        context,
        AppRoutes.checkin,
        arguments: missionId,
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Impossible d’accepter la mission.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionId = ModalRoute.of(context)?.settings.arguments as String?;

    if (missionId == null || missionId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Mission introuvable.'),
        ),
      );
    }

    final missionRef = FirebaseFirestore.instance
        .collection('missions')
        .doc(missionId);

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: missionRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Erreur lors du chargement de la mission :\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('Cette mission n’existe plus.'),
              );
            }

            final mission = snapshot.data!.data()!;

            return Column(
              children: [
                const PageHeader(
                  title: 'Détails mission',
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mission['title']?.toString() ?? 'Mission',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                mission['description']?.toString() ??
                                    'Aucune description.',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),

                              const Divider(height: 30),

                              _Info(
                                'Lieu',
                                mission['location']?.toString() ??
                                    'Non renseigné',
                              ),

                              _Info(
                                'Date',
                                mission['date']?.toString() ??
                                    'Non renseignée',
                              ),

                              _Info(
                                'Budget',
                                '${mission['budget'] ?? 0} FCFA',
                              ),

                              _Info(
                                'Statut',
                                mission['status']?.toString() ??
                                    'Non renseigné',
                              ),

                              if (mission['ownerName'] != null)
                                _Info(
                                  'Agriculteur',
                                  mission['ownerName'].toString(),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (user == null)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Connectez-vous pour pouvoir accepter cette mission.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _acceptMission(
                              context,
                              missionId,
                              mission,
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text(
                              'Accepter la mission',
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.checkin,
                                arguments: missionId,
                              );
                            },
                            icon: const Icon(
                              Icons.location_on_outlined,
                            ),
                            label: const Text(
                              'Faire le check-in',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info(
    this.label,
    this.value,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}