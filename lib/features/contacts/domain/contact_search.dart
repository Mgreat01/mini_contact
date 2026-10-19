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

List<Contact> searchContacts(
  List<Contact> contacts,
  String query, {
  String? circle,
  String? tag,
}) => ContactSearchIndex(contacts).search(query, circle: circle, tag: tag);

/// Derived data kept only in memory, rebuilt after a successful load or save.
class ContactSearchIndex {
  ContactSearchIndex(Iterable<Contact> contacts, {bool sortByName = false})
    : _entries = contacts.map(_SearchEntry.new).toList() {
    if (sortByName) {
      _entries.sort((a, b) {
        final order = a.name.compareTo(b.name);
        return order == 0 ? a.contact.id.compareTo(b.contact.id) : order;
      });
    }
  }

  final List<_SearchEntry> _entries;

  List<Contact> get contacts => List.unmodifiable(_entries.map((entry) => entry.contact));

  List<Contact> search(String query, {String? circle, String? tag}) {
    final normalized = normalizeContactText(query.trim());
    final circleKey = circle == null ? null : normalizeContactText(circle);
    final tagKey = tag == null ? null : normalizeContactText(tag);
    final tokens = normalized.split(RegExp(r'\s+'));
    final phoneQuery = RegExp(r'^\+?[\d\s().-]+$').hasMatch(normalized)
      ? normalized.replaceAll(RegExp(r'\D'), '') : '';
    final matches = _entries.where((entry) {
      if (circleKey != null && !entry.circles.contains(circleKey)) return false;
      if (tagKey != null && !entry.tags.contains(tagKey)) return false;
      if (normalized.isEmpty) return true;
      return (phoneQuery.isNotEmpty && entry.phone.contains(phoneQuery)) ||
        tokens.every(entry.text.contains);
    }).toList();
    if (normalized.isEmpty) return matches.map((entry) => entry.contact).toList();
    // Three stable passes favor exact names, then prefixes, then context matches.
    return [
      ...matches.where((entry) => entry.name == normalized),
      ...matches.where((entry) => entry.name != normalized && entry.name.startsWith(normalized)),
      ...matches.where((entry) => !entry.name.startsWith(normalized)),
    ].map((entry) => entry.contact).toList();
  }
}

class _SearchEntry {
  _SearchEntry(this.contact)
    : name = normalizeContactText(contact.name),
      phone = contact.phone.replaceAll(RegExp(r'\D'), ''),
      circles = contact.circles.map(normalizeContactText).toSet(),
      tags = contact.tags.map(normalizeContactText).toSet(),
      text = normalizeContactText(
        '${contact.name} ${contact.phone} ${contact.email} '
        '${contact.meetingContext} ${contact.notes} '
        '${contact.circles.join(' ')} ${contact.tags.join(' ')} '
        '${contact.interactions.map((interaction) => interaction.note).join(' ')}',
      );

  final Contact contact;
  final String name;
  final String phone;
  final String text;
  final Set<String> circles;
  final Set<String> tags;
}
