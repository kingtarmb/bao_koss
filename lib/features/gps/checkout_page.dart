// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../../shared/widgets/page_header.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      const PageHeader(title: 'Check-out'),
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Mission terminée ?', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(height: 150, decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.image_outlined, color: Colors.grey, size: 42)),
        const SizedBox(height: 16),
        const TextField(maxLines: 4, decoration: InputDecoration(
          labelText: 'Commentaire (optionnel)', hintText: 'Écrire un commentaire...')),
        const SizedBox(height: 18),
        FilledButton(onPressed: () => Navigator.pop(context),
          child: const Text('Valider le check-out')),
      ])),
    ])),
  );
}
