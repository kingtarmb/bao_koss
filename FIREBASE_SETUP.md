# BÂO-KOSS — configuration Firebase

Le ZIP volontairement **n'inclut pas les fichiers de configuration Firebase contenant des valeurs propres à ton compte**.

Dans le projet, exécute :

```powershell
flutterfire configure
flutter pub get
flutter analyze
flutter test
```

Choisis le projet Firebase `boa-koss` et Android/iOS/Web/Windows selon les plateformes utilisées.

## Auth
Active dans Firebase Authentication :
- Email/Password

Pour le mode téléphone + mot de passe utilisé par BÂO-KOSS, l'application conserve le téléphone comme identifiant utilisateur et crée un identifiant technique interne. Pour un vrai OTP SMS, il faudra ajouter la connexion Phone Auth.

## Firestore
Crée d'abord la base Cloud Firestore **par défaut** dans le projet `boa-koss` depuis la console Firebase :

1. Ouvre **Firestore Database**.
2. Clique sur **Create database**.
3. Choisis la base `(default)` et une région proche de tes utilisateurs.
4. Publie ensuite les règles fournies dans `firebase/firestore.rules` :

```powershell
firebase deploy --only firestore:rules --project boa-koss
```

L'application ne tente pas d'écrire dans Firestore avant authentification. Après avoir créé ton premier compte, donne-lui le rôle administrateur puis utilise l'initialisation des données maître depuis un contexte administrateur pour créer les batches et formations par défaut.

## Storage
Les photos de missions/check-in doivent être envoyées dans Firebase Storage dans une prochaine étape d'intégration avec URL persistante. Le code actuel enregistre déjà la référence locale de la photo dans le journal de présence ; ne considère pas cette référence comme une URL cloud.

## Premier administrateur
Après création du compte, modifie le document :
`users/{UID}`

et définis :
```text
role: admin
type: admin
```

Ne donne jamais le rôle admin depuis une interface publique.
