// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../../shared/widgets/page_header.dart';

class FarmersPage extends StatelessWidget {
  const FarmersPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      const PageHeader(title: 'Gestion des agriculteurs'),
      Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
        _f('Ferme Djarga', 'Djarga • Coton'),
        _f('Coopérative Belom', 'Belom • Maïs'),
        _f('Exploitation Koundoul', 'Koundoul • Maraîchage'),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Ajouter un agriculteur')),
      ])),
    ])),
  );
  Widget _f(String n, String s) => Card(child: ListTile(
    leading: const CircleAvatar(child: Icon(Icons.agriculture)),
    title: Text(n, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(s), trailing: const Icon(Icons.chevron_right)));
}
