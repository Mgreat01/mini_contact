import 'package:flutter/material.dart';
import '../domain/contact.dart';
import '../domain/relationship_dates.dart';

class AttentionsPage extends StatelessWidget {
  const AttentionsPage({
    super.key,
    required this.contacts,
    required this.saving,
    required this.onChanged,
    required this.onOpen,
    this.today,
  });

  final List<Contact> contacts;
  final bool saving;
  final ValueChanged<Contact> onChanged;
  final ValueChanged<Contact> onOpen;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final now = today ?? DateTime.now();
    final entries = <({Contact contact, DateTime date, ImportantDate? occasion, int index})>[
      for (final contact in contacts) ...[
        if (contact.reminder != null)
          (contact: contact, date: contact.reminder!.dueDate, occasion: null, index: -1),
        for (var index = 0; index < contact.importantDates.length; index++)
          (contact: contact, date: contact.importantDates[index].nextOccurrence(now),
            occasion: contact.importantDates[index], index: index),
      ],
    ]..sort((a, b) => a.date.compareTo(b.date));

    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Une pensée commence par une personne.\n'
            'Ajoutez un rappel ou une date importante dans sa fiche.',
            textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Une attention, à votre rythme',
                  style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('Des nouvelles à prendre et des moments à célébrer. '
                  'Vous choisissez quand.'),
              ],
            ),
          );
        }
        final entry = entries[index - 1];
        final contact = entry.contact;
        final reminder = contact.reminder;
        final occasion = entry.occasion;
        final date = entry.date;
        final dateLabel = date == localDay(now)
            ? 'Aujourd’hui'
            : date.isBefore(localDay(now))
              ? 'Quand vous le souhaitez · ${formatContactDate(date)}'
              : 'Le ${formatContactDate(date)}';
        return Card(
          key: ValueKey('${contact.id}-${entry.index}'),
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(occasion == null ? Icons.favorite_border : Icons.cake_outlined),
                  title: Text(contact.name),
                  subtitle: Text('${occasion?.title ?? 'Prendre des nouvelles'}\n$dateLabel'),
                  onTap: saving ? null : () => onOpen(contact),
                ),
                if (occasion == null && reminder != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: saving ? null : () => onChanged(contact.confirmContact(today ?? DateTime.now())),
                        icon: const Icon(Icons.check),
                        label: const Text('J’ai pris contact'),
                      ),
                      TextButton(
                        onPressed: saving ? null : () => onChanged(contact.copyWith(
                          reminder: reminder.postpone(today ?? DateTime.now()),
                        )),
                        child: const Text('Reporter de 7 jours'),
                      ),
                      TextButton(
                        onPressed: saving ? null : () => onChanged(contact.copyWith(clearReminder: true)),
                        child: const Text('Désactiver le rappel'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
