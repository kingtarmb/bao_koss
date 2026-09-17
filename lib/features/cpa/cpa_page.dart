// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/page_header.dart';

class CpaPage extends StatelessWidget {
  const CpaPage({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Vous devez être connecté.')),
      );
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Ma CPA'),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: userRef.snapshots(),
                builder: (context, profileSnapshot) {
                  if (!profileSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final profile = profileSnapshot.data?.data() ?? {};
                  final name =
                      '${profile['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'Utilisateur'}';
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: userRef
                        .collection('badges')
                        .where('status', isEqualTo: 'validated')
                        .snapshots(),
                    builder: (context, badgeSnapshot) {
                      final badges = badgeSnapshot.data?.docs ?? [];
                      return ListView(
                        padding: const EdgeInsets.all(14),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundImage:
                                        profile['photoUrl']
                                                ?.toString()
                                                .isNotEmpty ==
                                            true
                                        ? NetworkImage(
                                            profile['photoUrl'].toString(),
                                          )
                                        : null,
                                    child:
                                        profile['photoUrl']
                                                ?.toString()
                                                .isNotEmpty ==
                                            true
                                        ? null
                                        : const Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${profile['cpaNumber'] ?? 'Carte professionnelle agricole'}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2,
                                      size: 52,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _Row('Nom', name),
                          _Row('Village', '${profile['village'] ?? '—'}'),
                          _Row('Canton', '${profile['canton'] ?? '—'}'),
                          _Row(
                            'Sous-préfecture',
                            '${profile['subPrefecture'] ?? '—'}',
                          ),
                          _Row(
                            'Département',
                            '${profile['department'] ?? '—'}',
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Batchs validés',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (badges.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text('Aucun batch validé.'),
                            )
                          else
                            Wrap(
                              spacing: 6,
                              children: badges
                                  .map(
                                    (doc) => Chip(
                                      label: Text(
                                        '${doc.data()['name'] ?? 'Batch'}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'Carte professionnelle agricole de $name\n'
                                    'Village : ${profile['village'] ?? '—'}\n'
                                    'Batchs validés : ${badges.map((doc) => doc.data()['name'] ?? 'Batch').join(', ')}',
                              ),
                            ),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Télécharger / Partager'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BaoBottomNav(selectedIndex: 2),
    );
  }
}

class _Row extends StatelessWidget {
  final String a, b;
  const _Row(this.a, this.b);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(a), Text(b)],
    ),
  );
}
