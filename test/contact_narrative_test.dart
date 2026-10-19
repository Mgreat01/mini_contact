import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eli_contacts/features/contacts/data/local_contact_repository.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/app.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Les anciennes fiches restent lisibles sans champs narratifs', () {
    final contact = Contact.fromJson({
      'id': 'ancien',
      'name': 'Nadia',
      'phone': '123456789',
    });
    expect(contact.meetingContext, isEmpty);
    expect(contact.notes, isEmpty);
    expect(contact.email, isEmpty);
  });

  test('Le contexte et les notes survivent à la recréation du dépôt', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await LocalContactRepository(preferences).save([
      const Contact(
        id: 'nadia',
        name: 'Nadia',
        phone: '123456789',
        meetingContext: 'À l’atelier de cuisine, en juin',
        notes: 'Aime le jardinage.\nPréfère les messages.',
      ),
    ]);
    final restored = (await LocalContactRepository(preferences).load()).single;
    expect(restored.meetingContext, 'À l’atelier de cuisine, en juin');
    expect(restored.notes, 'Aime le jardinage.\nPréfère les messages.');
  });

  testWidgets('Modifier une fiche conserve son histoire et actualise la recherche', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalContactRepository(preferences);
    await repository.save([
      const Contact(
        id: '1',
        name: 'Nadia',
        phone: '123456789',
        meetingContext: 'Atelier de cuisine',
        notes: 'Aime le théâtre',
      ),
    ]);
    await tester.pumpWidget(ContactsApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'theatre');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nadia'));
    await tester.pumpAndSettle();
    expect(find.text('Notre rencontre'), findsOneWidget);
    expect(find.text('Aime le théâtre'), findsOneWidget);
    await tester.tap(find.byTooltip('Modifier le contact'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Nadia Martin');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Nadia Martin'), findsOneWidget);
    final restored = (await repository.load()).single;
    expect(restored.meetingContext, 'Atelier de cuisine');
    expect(restored.notes, 'Aime le théâtre');
  });
}
