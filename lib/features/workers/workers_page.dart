// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../../shared/widgets/page_header.dart';

class WorkersPage extends StatelessWidget {
  const WorkersPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      const PageHeader(title: 'Gestion des ouvriers'),
      Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
        _w('Paul Mbai', 'Récolte • Valide'),
        _w('Marie Sara', 'Semis • Valide'),
        _w('Joseph D.', 'Entretien • En cours'),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Ajouter un ouvrier')),
      ])),
    ])),
  );
  Widget _w(String n, String s) => Card(child: ListTile(
    leading: const CircleAvatar(child: Icon(Icons.person)),
    title: Text(n, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(s), trailing: const Icon(Icons.chevron_right)));
}
