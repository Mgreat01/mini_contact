import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eli_contacts/features/contacts/data/local_contact_repository.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';

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
}
