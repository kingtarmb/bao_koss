// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter_test/flutter_test.dart';

import 'package:bao_koss/core/app.dart';

void main() {
  testWidgets(
    'BÂO-KOSS affiche la page de connexion après la Splash',
    (WidgetTester tester) async {
      await tester.pumpWidget(const BaoKossApp());

      // Affichage initial de la Splash.
      await tester.pump();

      expect(find.textContaining('Bâo', findRichText: true), findsOneWidget);
      expect(find.textContaining('KOSS', findRichText: true), findsOneWidget);

      // Avance le temps exactement de la durée de la Splash (le Timer).
      await tester.pump(const Duration(seconds: 2));

      // Laisse la transition de navigation (route animation) se terminer.
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Téléphone'), findsNWidgets(2)); // segment + label du champ
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    },
  );
}