// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class BaoBottomNav extends StatelessWidget {
  final int selectedIndex;
  const BaoBottomNav({super.key, required this.selectedIndex});

  void _go(BuildContext context, int index) {
    final routes = [
      AppRoutes.home, AppRoutes.missions, AppRoutes.cpa,
      AppRoutes.payments, AppRoutes.badges, '/profile',
    ];
    if (index == selectedIndex) return;
    if (index == 5) {
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
      return;
    }
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Accueil','Missions','CPA','Paiements','Badges','Profil'];
    const icons = [Icons.home, Icons.work_outline, Icons.qr_code_2,
      Icons.account_balance_wallet_outlined, Icons.workspace_premium_outlined, Icons.person_outline];

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) => _go(context, i),
      destinations: List.generate(labels.length,
        (i) => NavigationDestination(icon: Icon(icons[i]), label: labels[i])),
    );
  }
}
