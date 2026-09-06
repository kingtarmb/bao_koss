// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BaoLogo extends StatelessWidget {
  final double size;
  const BaoLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.orange, width: 5),
      ),
      child: Icon(Icons.eco, color: AppTheme.green, size: size * .55),
    );
  }
}
