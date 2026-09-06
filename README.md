# BÂO-KOSS — Flutter

Projet Flutter structuré selon le wireframe fourni :
1. Splash
2. Connexion
3. Inscription
4. Tableau de bord
5. Missions
6. Détails mission
7. Check-in GPS
8. Check-out
9. Paiements
10. CPA
11. Badges
12. Signalement

## Architecture
- Flutter / Material 3
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- SQLite local
- Synchronisation locale → Firestore
- GPS / présence
- Authentification par téléphone ou e-mail + mot de passe

## IMPORTANT : Firebase
Le fichier `lib/firebase_options.dart` est un modèle compilable. Pour connecter le projet à ton Firebase `boa-koss`, lance dans le dossier du projet :

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Sélectionne le projet `boa-koss`.

Le fichier généré remplacera automatiquement le modèle.

## Android
Vérifie que `google-services.json` est placé dans :
`android/app/google-services.json`

Le fichier est volontairement absent du ZIP afin de ne pas exposer ta configuration locale.

## Installation
```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

## Compte de démonstration
L'écran de connexion accepte :
- E-mail + mot de passe
- Téléphone + mot de passe

Pour le téléphone, l'application transforme le numéro en identifiant Firebase interne. Cela permet de garder une expérience téléphone + mot de passe sans afficher l'e-mail à l'utilisateur.

## Signature
Tous les fichiers Dart du projet contiennent la signature binaire JOSTAR :
`01001010 01001111 01010011 01010100 01000001 01010010`
"# bao_koss" 
