import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eli_contacts/app.dart';
import 'package:eli_contacts/features/contacts/data/local_contact_repository.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/domain/contact_repository.dart';

class MemoryRepository implements ContactRepository {
  List<Contact> contacts = [];
  bool failSave = false;
  @override
  Future<List<Contact>> load() async => contacts;
  @override
  Future<void> save(List<Contact> values) async {
    if (failSave) throw StateError('Storage unavailable');
    contacts = values;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Les contacts sont conservés après recréation du dépôt', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalContactRepository(preferences);
    await repository.save([
      const Contact(
        id: '1',
        name: 'Élie',
        phone: '+243 123456789',
        email: 'elie@example.com',
      ),
    ]);
    final restored = await LocalContactRepository(preferences).load();
    expect(restored.single.name, 'Élie');
    expect(restored.single.phone, '+243 123456789');
    expect(restored.single.email, 'elie@example.com');
    await repository.save([]);
    expect(await repository.load(), isEmpty);
  });

  test(
    'Une sauvegarde corrompue déclenche une erreur sans être écrasée',
    () async {
      SharedPreferences.setMockInitialValues({
        LocalContactRepository.storageKey: 'invalid json',
      });
      final preferences = await SharedPreferences.getInstance();
      await expectLater(
        LocalContactRepository(preferences).load(),
        throwsFormatException,
      );
      expect(
        preferences.getString(LocalContactRepository.storageKey),
        'invalid json',
      );
    },
  );

  testWidgets('Ajout, validation, recherche, modification et suppression', (
    tester,
  ) async {
    final repository = MemoryRepository();
    await tester.pumpWidget(ContactsApp(repository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Ajoutez votre premier contact.'), findsOneWidget);
    await tester.tap(find.text('Ajouter un contact'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Saisissez un nom.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Alice');
    await tester.enterText(find.byType(TextFormField).at(1), '+33 612345678');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'alice@example.com',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(repository.contacts.single.name, 'Alice');
    await tester.enterText(find.byType(TextField), 'Bob');
    await tester.pumpAndSettle();
    expect(find.text('Aucun contact trouvé.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Alicia');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(repository.contacts.single.name, 'Alicia');
    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(repository.contacts, hasLength(1));
    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(repository.contacts, isEmpty);
  });

  testWidgets('Une erreur de sauvegarde conserve le contact affiché', (
    tester,
  ) async {
    final repository = MemoryRepository()
      ..contacts = [const Contact(id: '1', name: 'Alice', phone: '123456789')]
      ..failSave = true;
    await tester.pumpWidget(ContactsApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Sauvegarde impossible. Réessayez.'), findsOneWidget);
  });
}
