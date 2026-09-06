// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import 'firebase_bootstrap.dart';
import 'routes/app_routes.dart';
import '../shared/theme/app_theme.dart';

class BaoKossApp extends StatefulWidget {
  const BaoKossApp({super.key});

  @override
  State<BaoKossApp> createState() => _BaoKossAppState();
}

class _BaoKossAppState extends State<BaoKossApp> {
  @override
  void initState() {
    super.initState();
    FirebaseBootstrap.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BÂO-KOSS',
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
