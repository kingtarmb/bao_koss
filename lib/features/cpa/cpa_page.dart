// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/page_header.dart';

class CpaPage extends StatelessWidget {
  const CpaPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      const PageHeader(title: 'Ma CPA'),
      Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          const CircleAvatar(radius: 32, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CPA', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('TCD-LO-001-0001524'),
          ])),
          Container(width: 72, height: 72, color: Colors.black12,
            child: const Icon(Icons.qr_code_2, size: 52)),
        ]))),
        const SizedBox(height: 8),
        const _Row('Nom', 'Paul Mbai'),
        const _Row('Village', 'Djarga'),
        const _Row('Canton', 'Gounou Gaya'),
        const _Row('Sous-préfecture', 'Doba'),
        const _Row('Département', 'Logone Occidental'),
        const SizedBox(height: 10),
        const Text('Badges', style: TextStyle(fontWeight: FontWeight.w700)),
        const Wrap(spacing: 6, children: [
          Chip(label: Text('RÉCOLTE')), Chip(label: Text('SEMIS')),
          Chip(label: Text('ENTRETIEN')), Chip(label: Text('+2')),
        ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined),
          label: const Text('Télécharger / Partager')),
      ])),
    ])),
    bottomNavigationBar: const BaoBottomNav(selectedIndex: 2),
  );
}
class _Row extends StatelessWidget {
  final String a,b; const _Row(this.a,this.b);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a), Text(b)]));
}
