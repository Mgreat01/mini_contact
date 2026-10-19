import 'package:flutter/material.dart';
import '../domain/contact.dart';
import '../domain/contact_repository.dart';
import '../domain/contact_search.dart';
import 'contact_form.dart';
import 'contact_details.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, required this.repository});
  final ContactRepository repository;
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  List<Contact> _visible = [];
  String _query = '';
  bool _loading = true;
  bool _saving = false;
  bool _loadFailed = false;

  void _replaceContacts(List<Contact> contacts) {
    _contacts = List.of(contacts)
      ..sort((a, b) => normalizeContactText(a.name).compareTo(
        normalizeContactText(b.name),
      ));
    _visible = searchContacts(_contacts, _query);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final contacts = await widget.repository.load();
      if (mounted) setState(() => _replaceContacts(contacts));
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _persist(List<Contact> contacts) async {
    setState(() => _saving = true);
    try {
      await widget.repository.save(contacts);
      if (mounted) setState(() => _replaceContacts(contacts));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sauvegarde impossible. Réessayez.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit([Contact? contact]) async {
    final result = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (_) => contact == null
            ? const ContactForm()
            : ContactDetails(contact: contact),
      ),
    );
    if (result == null || !mounted) return;
    await _persist([
      ..._contacts.where((item) => item.id != result.id),
      result,
    ]);
  }

  Future<void> _delete(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce contact ?'),
        content: Text('Le contact ${contact.name} sera supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _persist(_contacts.where((item) => item.id != contact.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(title: const Text('Eli Contacts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading || _saving || _loadFailed ? null : () => _edit(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Ajouter un contact'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _loadFailed
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Impossible de charger les contacts.'),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _query = value.trim();
                          _visible = searchContacts(_contacts, _query);
                        }),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher un contact',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    if (_saving) const LinearProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${visible.length} contact(s)'),
                      ),
                    ),
                    Expanded(
                      child: visible.isEmpty
                          ? Center(
                              child: Text(
                                _contacts.isEmpty
                                    ? 'Ajoutez votre premier contact.'
                                    : 'Aucun contact trouvé.',
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 100,
                              ),
                              itemCount: visible.length,
                              itemBuilder: (context, index) {
                                final contact = visible[index];
                                return ListTile(
                                  leading: HeroMode(
                                    enabled: !MediaQuery.disableAnimationsOf(context),
                                    child: Hero(
                                      tag: 'contact-avatar-${contact.id}',
                                      child: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme.secondaryContainer,
                                        child: Text(
                                          contact.name.characters.first
                                              .toUpperCase(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(contact.name),
                                  subtitle: Text(
                                    [
                                      if (contact.meetingContext.isNotEmpty)
                                        contact.meetingContext
                                      else
                                        contact.phone,
                                    ].join('\n'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: _saving ? null : () => _edit(contact),
                                  trailing: IconButton(
                                    tooltip: 'Supprimer',
                                    onPressed: _saving
                                        ? null
                                        : () => _delete(contact),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
