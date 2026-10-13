import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/contact.dart';
import '../domain/contact_repository.dart';

class LocalContactRepository implements ContactRepository {
  LocalContactRepository(this.preferences);
  final SharedPreferences preferences;
  static const storageKey = 'eli_contacts_v1';

  @override
  Future<List<Contact>> load() async {
    final raw = preferences.getString(storageKey);
    if (raw == null) return [];
    final values = jsonDecode(raw) as List<dynamic>;
    return values
        .map((value) => Contact.fromJson(value as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<Contact> contacts) async {
    final saved = await preferences.setString(
      storageKey,
      jsonEncode(contacts.map((contact) => contact.toJson()).toList()),
    );
    if (!saved) throw StateError('La sauvegarde a échoué.');
  }
}
