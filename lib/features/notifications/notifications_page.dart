import 'package:flutter/material.dart';

import '../../shared/widgets/page_header.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const notifications = [
    (
      'Mission acceptée',
      'Votre mission Semis de maïs est prête pour le check-in.',
      Icons.check_circle_outline,
    ),
    (
      'Nouveau paiement',
      'Le paiement de Récolte de coton est disponible.',
      Icons.account_balance_wallet_outlined,
    ),
    (
      'Badge validé',
      'Votre badge Récolte a été validé.',
      Icons.workspace_premium_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Notifications'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(item.$3),
                      title: Text(
                        item.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(item.$2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
