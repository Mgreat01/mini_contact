import 'package:flutter/material.dart';
import '../domain/contact.dart';
import 'contact_form.dart';
import '../domain/relationship_dates.dart';
import 'interaction_history.dart';

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
              if (contact.circles.isNotEmpty || contact.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final circle in contact.circles)
                      Chip(avatar: const Icon(Icons.people_outline, size: 18),
                        label: Text('Cercle : $circle')),
                    for (final tag in contact.tags)
                      Chip(label: Text('#$tag')),
                  ],
                ),
                const SizedBox(height: 24),
              ],
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
              if (contact.interactions.isNotEmpty) ...[
                Semantics(
                  header: true,
                  child: Text('Nos moments', style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: 8),
                InteractionHistory(interactions: contact.interactions),
                const SizedBox(height: 24),
              ],
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
              if (contact.reminder != null)
                _StorySection(
                  title: 'Garder le lien',
                  text: 'Une attention tous les ${contact.reminder!.intervalDays} jours. '
                    'Prochaine date : ${formatContactDate(contact.reminder!.dueDate)}.',
                  icon: Icons.favorite_border,
                ),
              if (contact.importantDates.isNotEmpty)
                _StorySection(
                  title: 'Les dates qui comptent',
                  text: contact.importantDates.map((date) =>
                    '${date.title} · ${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}').join('\n'),
                  icon: Icons.cake_outlined,
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
