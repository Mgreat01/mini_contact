import 'package:flutter/material.dart';
import '../domain/contact.dart';
import 'contact_form.dart';

class ContactDetails extends StatelessWidget {
  const ContactDetails({super.key, required this.contact});

  final Contact contact;

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (_) => ContactForm(contact: contact)),
    );
    if (updated != null && context.mounted) Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Une personne, une histoire'),
        actions: [
          IconButton(
            tooltip: 'Modifier le contact',
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: HeroMode(
                  enabled: !MediaQuery.disableAnimationsOf(context),
                  child: Hero(
                    tag: 'contact-avatar-${contact.id}',
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      child: Text(
                        contact.name.characters.first.toUpperCase(),
                        style: theme.textTheme.headlineLarge,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                contact.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              if (contact.meetingContext.isNotEmpty)
                _StorySection(
                  title: 'Notre rencontre',
                  text: contact.meetingContext,
                  icon: Icons.waving_hand_outlined,
                ),
              if (contact.notes.isNotEmpty)
                _StorySection(
                  title: 'Ce que je veux retenir',
                  text: contact.notes,
                  icon: Icons.favorite_border,
                ),
              if (contact.meetingContext.isEmpty && contact.notes.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      const Text('Chaque lien a son histoire.'),
                      TextButton.icon(
                        onPressed: () => _edit(context),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Ajouter un souvenir'),
                      ),
                    ],
                  ),
                ),
              _StorySection(
                title: 'Coordonnées',
                text: [
                  contact.phone,
                  if (contact.email.isNotEmpty) contact.email,
                ].join('\n'),
                icon: Icons.contact_phone_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection({
    required this.title,
    required this.text,
    required this.icon,
  });

  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          SelectableText(text),
        ],
      ),
    ),
  );
}
