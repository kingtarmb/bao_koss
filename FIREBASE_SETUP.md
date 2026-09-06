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
Publie les règles fournies dans `firebase/firestore.rules` après vérification de tes besoins.

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
