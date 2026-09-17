# Structure BÂO-KOSS

lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── app.dart
│   ├── firebase_bootstrap.dart
│   ├── database/local_database.dart
│   ├── location/location_service.dart
│   ├── notifications/notification_service.dart
│   ├── sync/sync_service.dart
│   └── routes/app_routes.dart
├── shared/
│   ├── firebase_service.dart
│   ├── theme/app_theme.dart
│   └── widgets/
└── features/
    ├── auth/
    ├── dashboard/
    ├── missions/
    ├── gps/
    ├── payments/
    ├── cpa/
    ├── badges/
    ├── incidents/
    ├── workers/
    └── farmers/

La navigation suit le wireframe fourni et l'accès au dashboard passe d'abord par Splash → Connexion.

## Mise à jour (synchronisation complète)

- **Personnalisation** : l'accueil affiche désormais le vrai nom et le vrai
  rôle de la personne connectée (lecture `users/{uid}` en direct), et non
  plus un nom fixe.
- **Check-in / check-out** : les deux écrans sont liés à la mission
  concernée (`missionId` transmis par la navigation), utilisent la caméra
  et le GPS réels, et font progresser le statut de la mission
  (`accepted → in_progress → completed → validated`).
- **Cycle de vie d'une mission** : acceptation exclusive via une
  transaction Firestore (`FirebaseService.acceptMissionTransactional`),
  pour empêcher que deux ouvriers prennent la même mission ; validation
  finale par l'agriculteur (`mission_detail_page.dart`).
- **Mode hors-ligne** : la persistance Firestore est activée
  explicitement (`core/firebase_bootstrap.dart`) — les lectures/écritures
  de missions, statuts et présences fonctionnent hors connexion et se
  synchronisent seules au retour du réseau. Seul l'envoi de la **photo**
  vers Firebase Storage (non couvert par la persistance Firestore) est
  mis en file localement (`core/sync/sync_service.dart` +
  `core/database/local_database.dart`) et réessayé automatiquement
  (retour au premier plan + toutes les 45 s).
- **Notifications** : `core/notifications/notification_service.dart` est
  désormais réellement initialisé au démarrage.
- **Nettoyage** : tous les fichiers de l'ancien scaffolding non utilisés
  (dossiers `presentation/`, anciens `routes.dart`/`theme.dart`,
  modèles et services dupliqués) ont été supprimés — chaque fichier de
  `lib/` est désormais importé et utilisé quelque part.
