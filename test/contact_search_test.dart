import 'package:flutter_test/flutter_test.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/domain/contact_search.dart';

void main() {
  const contacts = [
    Contact(
      id: '1', name: 'Élie', phone: '+243 812 345 678',
      email: 'elie@example.com', meetingContext: 'Atelier de cuisine',
      notes: 'Aime les œuvres de théâtre.',
      circles: ['Amis', 'Travail'], tags: ['Équipe jardin'],
    ),
    Contact(id: '2', name: 'Nadia', phone: '0987654321'),
  ];

  test('Retrouve une personne par accent, coordonnées et souvenir', () {
    for (final query in [
      'ELIE', 'elie@example', '+243812345678', '812-345-678',
      'cuisine', 'oeuvres', 'theatre', 'elie cuisine', 'E\u0301lie',
    ]) {
      expect(searchContacts(contacts, query).single.id, '1', reason: query);
    }
  });

  test('Une recherche vide conserve l’ordre et les mots sont tous requis', () {
    expect(searchContacts(contacts, '  '), contacts);
    expect(searchContacts(contacts, 'nadia cuisine'), isEmpty);
    expect(searchContacts(contacts, 'inconnu'), isEmpty);
    expect(contacts.first.name, 'Élie');
  });

  test('Les filtres de cercle, tag et recherche se combinent sans doublons', () {
    expect(searchContacts(contacts, 'equipe jardin').single.id, '1');
    expect(searchContacts(contacts, '', circle: 'amis').single.id, '1');
    expect(searchContacts(contacts, 'cuisine', circle: 'Amis', tag: 'equipe jardin').single.id, '1');
    expect(searchContacts(contacts, '', circle: 'Famille'), isEmpty);
    expect(searchContacts(contacts, 'Nadia', circle: 'Travail'), isEmpty);
    expect(searchContacts(contacts, '', circle: 'Amis', tag: 'Autre'), isEmpty);
  });

  test('Les noms exacts puis les préfixes précèdent les souvenirs', () {
    final index = ContactSearchIndex(const [
      Contact(id: '1', name: 'Zoé', phone: '123456789', notes: 'Amie de Nadia'),
      Contact(id: '2', name: 'Nadia Martin', phone: '123456789'),
      Contact(id: '3', name: 'Nadia', phone: '123456789'),
    ]);
    expect(index.search('nadia').map((contact) => contact.id), ['3', '2', '1']);
    expect(index.search('').map((contact) => contact.id), ['1', '2', '3']);
  });
}
