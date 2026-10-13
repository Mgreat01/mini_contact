import 'contact.dart';

abstract interface class ContactRepository {
  Future<List<Contact>> load();
  Future<void> save(List<Contact> contacts);
}
