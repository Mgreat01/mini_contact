import 'package:flutter/material.dart';
import '../domain/contact.dart';
import '../domain/contact_repository.dart';
import '../domain/contact_search.dart';
import 'contact_form.dart';
import 'contact_details.dart';
import 'contact_filters.dart';
import 'attentions_page.dart';
import 'dart:async';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, required this.repository});
  final ContactRepository repository;
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> with WidgetsBindingObserver {
  List<Contact> _contacts = [];
  List<Contact> _visible = [];
  String _query = '';
  String? _circle;
  String? _tag;
  bool _loading = true;
  bool _saving = false;
  bool _loadFailed = false;
  int _tab = 0;
  Timer? _calendarTimer;

  void _refreshCalendar() {
    _calendarTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _calendarTimer = Timer(midnight.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _refreshCalendar();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _refreshCalendar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _calendarTimer?.cancel();
    super.dispose();
  }

  void _replaceContacts(List<Contact> contacts) {
    _contacts = List.of(contacts)
      ..sort((a, b) => normalizeContactText(a.name).compareTo(
        normalizeContactText(b.name),
      ));
    _filter();
  }

  void _filter() {
    _visible = searchContacts(_contacts, _query, circle: _circle, tag: _tag);
  }

  Future<void> _chooseFilters() async {
    final result = await showContactFilters(
      context, contacts: _contacts, circle: _circle, tag: _tag,
    );
    if (result == null || !mounted) return;
    setState(() {
      (_circle, _tag) = result;
      _filter();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshCalendar();
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
    if (_saving) return;
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

  Future<void> _updateContact(Contact contact) => _persist([
    ..._contacts.where((item) => item.id != contact.id),
    contact,
  ]);

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
    await _updateContact(result);
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
      appBar: AppBar(title: Text(_tab == 0 ? 'Eli Contacts' : 'À penser')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'À penser'),
        ],
      ),
      floatingActionButton: _tab == 0 ? FloatingActionButton.extended(
        onPressed: _loading || _saving || _loadFailed ? null : () => _edit(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Ajouter un contact'),
      ) : null,
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
              : _tab == 1
              ? Column(
                  children: [
                    if (_saving) const LinearProgressIndicator(),
                    Expanded(child: AttentionsPage(
                      contacts: _contacts,
                      saving: _saving,
                      onChanged: _updateContact,
                      onOpen: _edit,
                    )),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _query = value.trim();
                          _filter();
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
                      child: Row(
                        children: [
                          Expanded(child: Text('${visible.length} contact(s)')),
                          TextButton.icon(
                            onPressed: _saving ? null : _chooseFilters,
                            icon: const Icon(Icons.tune),
                            label: const Text('Filtrer'),
                          ),
                        ],
                      ),
                    ),
                    if (_circle != null || _tag != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (_circle != null) InputChip(
                                label: Text('Cercle : $_circle'),
                                onDeleted: () => setState(() { _circle = null; _filter(); }),
                              ),
                              if (_tag != null) InputChip(
                                label: Text('Tag : $_tag'),
                                onDeleted: () => setState(() { _tag = null; _filter(); }),
                              ),
                            ],
                          ),
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
                                  key: ValueKey(contact.id),
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
