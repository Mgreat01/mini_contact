import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/data/local_contact_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Les anciennes fiches n’ont ni cercles ni tags', () {
    final contact = Contact.fromJson({'id': '1', 'name': 'Nadia', 'phone': '123456789'});
    expect(contact.circles, isEmpty);
    expect(contact.tags, isEmpty);
  });

  test('Renommer un contact conserve ses appartenances après relecture', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = LocalContactRepository(await SharedPreferences.getInstance());
    const contact = Contact(
      id: '1', name: 'Nadia', phone: '123456789',
      circles: ['Famille', 'Amis'], tags: ['Cuisine', 'Kinshasa'],
    );
    await repository.save([contact.copyWith(name: 'Nadia Martin')]);
    final restored = (await repository.load()).single;
    expect(restored.name, 'Nadia Martin');
    expect(restored.circles, ['Famille', 'Amis']);
    expect(restored.tags, ['Cuisine', 'Kinshasa']);
  });
}
