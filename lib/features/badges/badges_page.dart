// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/theme/app_theme.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Mes badges'),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('badges')
                    .where('status', isEqualTo: 'validated')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final badges = snapshot.data?.docs ?? [];
                  if (badges.isEmpty) {
                    return _demoBadges();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final data = badges[index].data();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.orange.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_outlined,
                              color: AppTheme.orange,
                            ),
                          ),
                          title: Text(
                            '${data['name'] ?? 'Badge'}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Certification : ${data['certifiedAt'] ?? 'Date non renseignée'}',
                          ),
                          trailing: Text(
                            '${data['score'] ?? ''}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.green,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BaoBottomNav(selectedIndex: 4),
    );
  }

  Widget _demoBadges() {
    const demo = [
      ('PREPA', 'Validé', Colors.green),
      ('SEMIS', 'Validé', Colors.green),
      ('ENTRETIEN', 'Validé', Colors.green),
      ('TRAITEMENT', 'En cours', Colors.orange),
      ('RÉCOLTE', 'Validé', Colors.green),
      ('POST_RÉCOLTE', 'En cours', Colors.orange),
      ('POLYVALENT', 'Non validé', Colors.red),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: demo.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final badge = demo[index];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(
              badge.$1,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: Chip(
              label: Text(badge.$2),
              labelStyle: TextStyle(color: badge.$3, fontSize: 11),
            ),
          ),
        );
      },
    );
  }
}
