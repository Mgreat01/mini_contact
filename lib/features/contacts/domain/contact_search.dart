import 'contact.dart';

String normalizeContactText(String value) {
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a',
    'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i', 'ì': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o', 'ò': 'o', 'õ': 'o', 'œ': 'oe',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u', 'ÿ': 'y', 'ñ': 'n', 'æ': 'ae',
  };
  var normalized = value.toLowerCase();
  for (final entry in accents.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  return normalized.replaceAll(RegExp(r'[\u0300-\u036f]'), '');
}

List<Contact> searchContacts(List<Contact> contacts, String query) {
  final normalized = normalizeContactText(query.trim());
  if (normalized.isEmpty) return List.of(contacts);
  final tokens = normalized.split(RegExp(r'\s+'));
  final phoneQuery = RegExp(r'^\+?[\d\s().-]+$').hasMatch(normalized)
      ? normalized.replaceAll(RegExp(r'\D'), '')
      : '';
  return contacts.where((contact) {
    if (phoneQuery.isNotEmpty &&
        contact.phone.replaceAll(RegExp(r'\D'), '').contains(phoneQuery)) {
      return true;
    }
    final text = normalizeContactText(
      '${contact.name} ${contact.phone} ${contact.email} '
      '${contact.meetingContext} ${contact.notes}',
    );
    return tokens.every(text.contains);
  }).toList();
}
