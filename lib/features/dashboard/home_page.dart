// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget mission(BuildContext c, String title, String place, String date) => Card(
    child: ListTile(
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('$place\n$date'),
      trailing: const Chip(label: Text('Confirmée')),
      onTap: () => Navigator.pushNamed(c, AppRoutes.missionDetail),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bonjour, Paul 👋', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        Text('Ouvrier', style: TextStyle(fontSize: 11)),
      ]),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
    ),
    body: ListView(padding: const EdgeInsets.all(14), children: [
      Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.badge_outlined)),
          title: const Text('Ma CPA', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Valide'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.cpa),
        ),
      ),
      const SizedBox(height: 12),
      const Text('Missions à venir', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      mission(context, 'Récolte de coton', 'Village Djarga', '05/06/2026 • 07:00'),
      mission(context, 'Semis de maïs', 'Village Belom', '10/06/2026 • 07:00'),
      const SizedBox(height: 8),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6, children: [
          _Quick('Mes missions', Icons.assignment_outlined, AppRoutes.missions),
          _Quick('Mes paiements', Icons.account_balance_wallet_outlined, AppRoutes.payments),
          _Quick('Mes badges', Icons.workspace_premium_outlined, AppRoutes.badges),
          _Quick('Signaler incident', Icons.info_outline, AppRoutes.incident),
        ].map((q) => Card(child: InkWell(
          onTap: () => Navigator.pushNamed(context, q.route),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(q.icon, color: AppTheme.green, size: 28),
            const SizedBox(height: 7),
            Text(q.title, textAlign: TextAlign.center),
          ]),
        ))).toList(),
      ),
      const SizedBox(height: 10),
      OutlinedButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.missions),
        child: const Text('Voir toutes les missions')),
    ]),
    bottomNavigationBar: const BaoBottomNav(selectedIndex: 0),
  );
}

class _Quick {
  final String title, route; final IconData icon;
  _Quick(this.title, this.icon, this.route);
}
