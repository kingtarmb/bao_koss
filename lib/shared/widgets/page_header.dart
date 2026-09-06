// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  const PageHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        Expanded(
          child: Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
