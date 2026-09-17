// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/page_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Vous devez être connecté.')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Mon profil'),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.data() ?? {};
                  final authUser = FirebaseAuth.instance.currentUser;
                  final name =
                      data['name'] ?? authUser?.displayName ?? 'Utilisateur';
                  final batchId = data['batchId']?.toString();

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: batchId == null
                        ? const Stream.empty()
                        : FirebaseFirestore.instance
                              .collection('batches')
                              .where('id', isEqualTo: batchId)
                              .snapshots(),
                    builder: (context, batchSnapshot) {
                      final batchName =
                          batchSnapshot.data?.docs.firstOrNull
                              ?.data()['name']
                              ?.toString() ??
                          'Aucun batch';

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(14, 28, 14, 24),
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: AppTheme.green,
                            backgroundImage:
                                data['photoUrl']?.toString().isNotEmpty == true
                                ? NetworkImage(data['photoUrl'].toString())
                                : null,
                            child:
                                data['photoUrl']?.toString().isNotEmpty == true
                                ? null
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              name.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _row(
                            'Rôle',
                            '${data['role'] ?? data['type'] ?? '—'}',
                          ),
                          _row('Batch', batchName),
                          _row('Téléphone', '${data['phone'] ?? '—'}'),
                          _row(
                            'E-mail',
                            '${data['email'] ?? authUser?.email ?? '—'}',
                          ),
                          _row('Localité', '${data['village'] ?? '—'}'),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.editProfile,
                            ),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Modifier le profil'),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.trainings,
                            ),
                            icon: const Icon(Icons.school_outlined),
                            label: const Text('Mes formations'),
                          ),
                          if (data['role'] == 'admin')
                            OutlinedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.admin),
                              icon: const Icon(
                                Icons.admin_panel_settings_outlined,
                              ),
                              label: const Text('Administration'),
                            ),
                          OutlinedButton.icon(
                            onPressed: () => _signOut(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Se déconnecter'),
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
      bottomNavigationBar: const BaoBottomNav(selectedIndex: 5),
    );
  }

  Widget _row(String label, String value) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}
