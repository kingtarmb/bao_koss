// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../theme/app_theme.dart';

class BaoBottomNav extends StatelessWidget {
  final int selectedIndex;
  const BaoBottomNav({super.key, required this.selectedIndex});

  void _go(BuildContext context, int index) {
    final routes = [
      AppRoutes.home,
      AppRoutes.missions,
      AppRoutes.cpa,
      AppRoutes.payments,
      AppRoutes.badges,
      AppRoutes.profile,
    ];

    if (index == selectedIndex) return;
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Accueil', Icons.home_outlined),
      _NavItem('Missions', Icons.assignment_outlined),
      _NavItem('CPA', Icons.qr_code_2_outlined),
      _NavItem('Paiements', Icons.account_balance_wallet_outlined),
      _NavItem('Badges', Icons.workspace_premium_outlined),
      _NavItem('Profil', Icons.person_outline),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.green,
        unselectedItemColor: Colors.grey.shade600,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (i) => _go(context, i),
        items: items
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem(this.label, this.icon);
}
