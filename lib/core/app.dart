// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'dart:async';
import 'package:flutter/material.dart';
import 'firebase_bootstrap.dart';
import 'notifications/notification_service.dart';
import 'routes/app_routes.dart';
import 'sync/sync_service.dart';
import '../shared/theme/app_theme.dart';

class BaoKossApp extends StatefulWidget {
  const BaoKossApp({super.key});

  @override
  State<BaoKossApp> createState() => _BaoKossAppState();
}

class _BaoKossAppState extends State<BaoKossApp> with WidgetsBindingObserver {
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseBootstrap.initialize().then((_) {
      SyncService().trySyncSilently();
      NotificationService().initialize();
    });

    // Filet de sécurité : au cas où la connexion revient pendant que
    // l'application reste ouverte au premier plan (sans passer par un
    // retour en arrière-plan/premier plan), on retente périodiquement les
    // éléments encore en file (essentiellement les photos de présence).
    _syncTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => SyncService().trySyncSilently(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // L'utilisateur revient dans l'app (souvent après avoir retrouvé du
      // réseau) : on tente immédiatement de vider la file d'attente locale.
      SyncService().trySyncSilently();
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
