import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eli_contacts/app.dart';
import 'package:eli_contacts/features/contacts/data/local_contact_repository.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/domain/relationship_dates.dart';

void main() {
  Future<LocalContactRepository> repository() async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalContactRepository(await SharedPreferences.getInstance());
    await store.save([
      Contact(
        id: '1', name: 'Nadia', phone: '123456789', notes: 'Aime le théâtre',
        circles: const ['Amis', 'Travail'], tags: const ['Cuisine'],
        reminder: ContactReminder(intervalDays: 7, anchorDate: DateTime(2020)),
      ),
      const Contact(id: '2', name: 'Bob', phone: '987654321', circles: ['Famille']),
    ]);
    return store;
  }

  testWidgets('Les filtres se combinent et s’effacent sans changer les fiches', (tester) async {
    final store = await repository();
    await tester.pumpWidget(ContactsApp(repository: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filtrer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amis'));
    await tester.pump();
    await tester.tap(find.text('Cuisine'));
    await tester.pump();
    await tester.tap(find.text('Afficher les contacts'));
    await tester.pumpAndSettle();
    expect(find.text('Nadia'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
    expect(find.text('Cercle : Amis'), findsOneWidget);
    expect(find.text('Tag : Cuisine'), findsOneWidget);
    await tester.tap(find.text('Filtrer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Effacer les filtres'));
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsOneWidget);
    expect((await store.load()), hasLength(2));
  });

  testWidgets('La recherche survit au changement d’onglet et les reports sont persistés', (tester) async {
    final store = await repository();
    await tester.pumpWidget(ContactsApp(repository: store));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'theatre');
    await tester.pumpAndSettle();
    await tester.tap(find.text('À penser'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reporter de 7 jours'));
    await tester.pumpAndSettle();
    expect((await store.load()).firstWhere((contact) => contact.id == '1').reminder!.snoozedUntil, isNotNull);
    await tester.tap(find.text('Contacts'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'theatre');
    expect(find.text('Nadia'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });
}
