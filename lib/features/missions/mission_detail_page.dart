// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/firebase_service.dart';
import '../../shared/widgets/page_header.dart';

class MissionDetailPage extends StatelessWidget {
  final String? missionId;

  const MissionDetailPage({super.key, this.missionId});

  Future<void> _acceptMission(
    BuildContext context,
    String missionId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour accepter une mission.')),
      );
      return;
    }

    try {
      final accepted = await FirebaseService().acceptMissionTransactional(
        missionId: missionId,
        workerId: user.uid,
        workerEmail: user.email,
      );

      if (!context.mounted) return;

      if (!accepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cette mission vient d’être prise par un autre ouvrier.')),
        );
        return;
      }

      // Trace de candidature (historique), en plus du champ workerId
      // désormais posé sur la mission elle-même par la transaction.
      unawaited(FirebaseFirestore.instance
          .collection('missionApplications')
          .doc('${missionId}_${user.uid}')
          .set({
        'missionId': missionId,
        'workerId': user.uid,
        'workerEmail': user.email,
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
      }));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission acceptée avec succès.')),
      );

      Navigator.pushNamed(context, AppRoutes.checkin, arguments: missionId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’accepter la mission.\n$e')),
      );
    }
  }

  Future<void> _validateMission(BuildContext context, String missionId) async {
    try {
      await FirebaseService().updateMissionStatus(missionId, 'validated');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission validée. Elle peut maintenant être payée.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de valider la mission.\n$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgument = ModalRoute.of(context)?.settings.arguments;
    final missionId = this.missionId ??
        (routeArgument is String ? routeArgument : null);

    if (missionId == null || missionId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Mission introuvable.')),
      );
    }

    final missionRef = FirebaseFirestore.instance.collection('missions').doc(missionId);
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

            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Cette mission n’existe plus.'));
            }

            final mission = snapshot.data!.data()!;
            final status = mission['status']?.toString() ?? 'published';
            final workerId = mission['workerId'] as String?;
            final farmerId = mission['farmerId'] as String?;
            final isAssignedWorker = user != null && workerId == user.uid;
            final isOwnerFarmer = user != null && farmerId == user.uid;

            return Column(
              children: [
                const PageHeader(title: 'Détails mission'),
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
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                mission['description']?.toString() ?? 'Aucune description.',
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    _Info('Lieu', mission['location']?.toString() ?? 'Non renseigné'),
                                    _Info('Date', mission['date']?.toString() ?? 'Non renseignée'),
                                    _Info('Budget', '${mission['budget'] ?? 0} FCFA'),
                                    _Info('Check-in', '${mission['checkInCount'] ?? 0} fois'),
                                    _Info('Check-out', '${mission['checkOutCount'] ?? 0} fois'),
                                    _Info('Statut', _statusLabel(status)),
                                    if (mission['ownerName'] != null)
                                      _Info('Agriculteur', mission['ownerName'].toString()),
                                  ],
                                ),
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
                              'Connectez-vous pour pouvoir agir sur cette mission.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ..._actionsFor(
                          context: context,
                          missionId: missionId,
                          status: status,
                          workerId: workerId,
                          isAssignedWorker: isAssignedWorker,
                          isOwnerFarmer: isOwnerFarmer,
                        ),
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

  static String _statusLabel(String status) {
    switch (status) {
      case 'published':
        return 'Publiée';
      case 'accepted':
        return 'Acceptée';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée (en attente de validation)';
      case 'validated':
        return 'Validée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  List<Widget> _actionsFor({
    required BuildContext context,
    required String missionId,
    required String status,
    required String? workerId,
    required bool isAssignedWorker,
    required bool isOwnerFarmer,
  }) {
    // Mission encore libre : n'importe quel ouvrier peut la prendre.
    if (status == 'published' && (workerId == null || workerId.isEmpty)) {
      return [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _acceptMission(context, missionId),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Accepter la mission'),
          ),
        ),
      ];
    }

    // Après chaque check-out non final, la mission revient à l'état accepté.
    if (status == 'accepted' && isAssignedWorker) {
      return [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.checkin, arguments: missionId),
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('Faire le check-in'),
          ),
        ),
      ];
    }

    // Mission en cours pour MOI : je peux faire le check-out.
    if (status == 'in_progress' && isAssignedWorker) {
      return [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout, arguments: missionId),
            icon: const Icon(Icons.logout),
            label: const Text('Faire le check-out'),
          ),
        ),
      ];
    }

    // Mission terminée par l'ouvrier : l'agriculteur qui l'a publiée valide.
    if (status == 'completed' && isOwnerFarmer) {
      return [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _validateMission(context, missionId),
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Valider la mission'),
          ),
        ),
      ];
    }

    if (status == 'completed' && isAssignedWorker) {
      return const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Mission terminée. En attente de validation par l’agriculteur.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }

    if (status == 'validated') {
      return const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('✅ Mission validée.', textAlign: TextAlign.center),
          ),
        ),
      ];
    }

    return const [];
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
