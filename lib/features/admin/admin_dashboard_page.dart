// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../shared/firebase_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<void> _seedMasterData(BuildContext context) async {
    try {
      await FirebaseService().ensureMasterData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batches et formations initialisés.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Initialisation impossible : $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            'Tableau de bord administrateur',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Données en temps réel de BÂO-KOSS',
          ),

          const SizedBox(height: 20),

          _count(
            title: 'Utilisateurs',
            collection: 'users',
            icon: Icons.people,
          ),

          _count(
            title: 'Missions',
            collection: 'missions',
            icon: Icons.work_outline,
          ),

          _count(
            title: 'Formations',
            collection: 'trainings',
            icon: Icons.school_outlined,
          ),

          _count(
            title: 'Paiements',
            collection: 'payments',
            icon: Icons.payments_outlined,
          ),

          _count(
            title: 'Incidents',
            collection: 'incidents',
            icon: Icons.report_problem_outlined,
          ),

          const SizedBox(height: 20),

          const Text(
            'Gestion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          _adminAction(
            context,
            icon: Icons.people_outline,
            title: 'Utilisateurs',
            subtitle: 'Consulter et gérer les comptes',
            onTap: () {
              // Page utilisateurs à connecter
            },
          ),

          _adminAction(
            context,
            icon: Icons.work_outline,
            title: 'Missions',
            subtitle: 'Contrôler les missions et leur statut',
            onTap: () {
              // Page missions admin à connecter
            },
          ),

          _adminAction(
            context,
            icon: Icons.school_outlined,
            title: 'Formations',
            subtitle: 'Créer et gérer les formations',
            onTap: () {
              // Page formations admin à connecter
            },
          ),

          _adminAction(
            context,
            icon: Icons.cloud_upload_outlined,
            title: 'Initialiser les données maître',
            subtitle: 'Créer les 10 batches et formations par défaut',
            onTap: () => _seedMasterData(context),
          ),

          _adminAction(
            context,
            icon: Icons.verified_outlined,
            title: 'Certifications et badges',
            subtitle: 'Valider les certifications des ouvriers',
            onTap: () {
              // Page certifications à connecter
            },
          ),

          _adminAction(
            context,
            icon: Icons.payments_outlined,
            title: 'Paiements',
            subtitle: 'Consulter les paiements réels',
            onTap: () {
              // Page paiements admin à connecter
            },
          ),

          _adminAction(
            context,
            icon: Icons.report_problem_outlined,
            title: 'Incidents',
            subtitle: 'Traiter les signalements',
            onTap: () {
              // Page incidents admin à connecter
            },
          ),
        ],
      ),
    );
  }

  Widget _count({
    required String title,
    required String collection,
    required IconData icon,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: const Text(
                'Impossible de charger les données',
              ),
              trailing: const Icon(
                Icons.error_outline,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              leading: Icon(icon),
              title: Text(title),
              trailing: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        final count = snapshot.data?.docs.length ?? 0;

        return Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: Text(
              '$count',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _adminAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}