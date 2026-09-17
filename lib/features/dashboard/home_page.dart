// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/firebase_service.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/theme/app_theme.dart';

/// Libellés français affichés pour chaque rôle stocké dans Firestore
/// (users/{uid}.role).
const Map<String, String> _roleLabels = {
  'ouvrier': 'Ouvrier',
  'agriculteur': 'Agriculteur',
  'employe': 'Employé',
  'formateur': 'Formateur',
  'superviseur': 'Superviseur',
  'admin_provincial': 'Administrateur provincial',
  'super_admin': 'Super administrateur',
};

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Mes missions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.missions);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Mes paiements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.payments);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mon profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget mission(
    BuildContext c, {
    required String missionId,
    required String title,
    required String place,
    required String date,
    required String status,
  }) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () =>
          Navigator.pushNamed(c, AppRoutes.missionDetail, arguments: missionId),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: AppTheme.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(place, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Chip(
              label: Text(_statusLabel(status)),
              backgroundColor: AppTheme.green.withValues(alpha: 0.10),
              labelStyle: const TextStyle(
                color: AppTheme.greenDark,
                fontSize: 11,
              ),
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    ),
  );

  static String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Acceptée';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'validated':
        return 'Validée';
      default:
        return 'Confirmée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Ouvrir le menu',
          onPressed: () => _showMenu(context),
        ),
        title: user == null
            ? const Text(
                'Bonjour 👋',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              )
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: service.userProfile(user.uid),
                builder: (context, snap) {
                  final data = snap.data?.data();
                  final name =
                      (data?['name'] as String?)?.trim().isNotEmpty == true
                      ? data!['name'] as String
                      : (user.displayName?.trim().isNotEmpty == true
                            ? user.displayName!
                            : 'Utilisateur');
                  final roleKey = data?['role'] as String? ?? 'ouvrier';
                  final roleLabel = _roleLabels[roleKey] ?? 'Ouvrier';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $name 👋',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        roleLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                },
              ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: AppTheme.beige,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.badge_outlined, color: Colors.white),
              ),
              title: const Text(
                'Ma CPA',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Valide'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.cpa),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mes missions à venir',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (user == null)
            const Text('Connectez-vous pour voir vos missions.')
          else
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: service.missions
                  .where('workerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs =
                    (snap.data?.docs ?? [])
                        .where((d) => d.data()['status'] != 'validated')
                        .toList()
                      ..sort(
                        (a, b) => (a.data()['date'] ?? '').toString().compareTo(
                          (b.data()['date'] ?? '').toString(),
                        ),
                      );

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucune mission en cours pour le moment.'),
                  );
                }

                return Column(
                  children: docs.take(3).map((doc) {
                    final data = doc.data();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: mission(
                        context,
                        missionId: doc.id,
                        title: data['title']?.toString() ?? 'Mission',
                        place:
                            data['location']?.toString() ??
                            'Lieu non renseigné',
                        date: data['date']?.toString() ?? '',
                        status: data['status']?.toString() ?? 'accepted',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children:
                [
                      _Quick(
                        'Mes missions',
                        Icons.assignment_outlined,
                        AppRoutes.missions,
                      ),
                      _Quick(
                        'Mes paiements',
                        Icons.account_balance_wallet_outlined,
                        AppRoutes.payments,
                      ),
                      _Quick(
                        'Mes badges',
                        Icons.workspace_premium_outlined,
                        AppRoutes.badges,
                      ),
                      _Quick(
                        'Signaler incident',
                        Icons.info_outline,
                        AppRoutes.incident,
                      ),
                    ]
                    .map(
                      (q) => Card(
                        color: AppTheme.softGray,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.pushNamed(context, q.route),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(q.icon, color: AppTheme.green, size: 28),
                              const SizedBox(height: 7),
                              Text(
                                q.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.missions),
            child: const Text('Voir toutes les missions'),
          ),
        ],
      ),
      bottomNavigationBar: const BaoBottomNav(selectedIndex: 0),
    );
  }
}

class _Quick {
  final String title, route;
  final IconData icon;
  _Quick(this.title, this.icon, this.route);
}
