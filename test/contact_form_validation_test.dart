import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/presentation/contact_form.dart';

void main() {
  testWidgets('Les champs obligatoires restent validés même après défilement', (tester) async {
    Contact? saved;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            saved = await Navigator.push<Contact>(context,
              MaterialPageRoute(builder: (_) => const ContactForm()));
          },
          child: const Text('Ouvrir'),
        ),
      )),
    ));
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
    expect(find.byType(ContactForm), findsOneWidget);
    expect(find.text('Saisissez un nom.'), findsOneWidget);
    expect(find.text('Saisissez un numéro valide (au moins 6 chiffres).'), findsOneWidget);
  });
}
