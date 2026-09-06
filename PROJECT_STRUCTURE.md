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
