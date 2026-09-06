# BÂO-KOSS — version de travail fonctionnelle

Cette version remplace les principales données fictives par des lectures/écritures Firestore et prépare les modules missions, présence GPS, paiements, formations, badges, profil et administration.

## Signature
Tous les fichiers sources modifiés portent en tête :
`JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010`

## Installation
1. Installer Flutter et Android Studio.
2. Dans le dossier : `flutter pub get`
3. Configurer Firebase : `flutterfire configure`
4. Vérifier : `flutter analyze`
5. Tester : `flutter test`
6. Construire : `flutter build apk --release`

## Sécurité
Aucun `firebase_options.dart` personnel n'est distribué dans cette archive. Il doit être régénéré localement avec FlutterFire.

## Données Firestore utilisées
`users`, `missions`, `attendance`, `payments`, `trainings`, `evaluations`, `incidents`.

## Important
Les règles Firestore/Storage fournies sont des bases de départ à adapter avant production. Les paiements ne doivent pas être considérés comme validés par le seul client Flutter : une validation serveur/admin est nécessaire.
