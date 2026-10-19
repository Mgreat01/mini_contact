import 'package:flutter/material.dart';
import '../domain/relationship_dates.dart';

class RelationshipEditor extends StatelessWidget {
  const RelationshipEditor({
    super.key,
    required this.reminder,
    required this.dates,
    required this.onReminderChanged,
    required this.onDatesChanged,
  });

  final ContactReminder? reminder;
  final List<ImportantDate> dates;
  final ValueChanged<ContactReminder?> onReminderChanged;
  final ValueChanged<List<ImportantDate>> onDatesChanged;

  Future<void> _editDate(BuildContext context, {int? index, bool birthday = false}) async {
    final result = await showDialog<ImportantDate>(
      context: context,
      builder: (_) => _DateDialog(
        initial: index == null ? null : dates[index],
        birthday: birthday,
      ),
    );
    if (result == null) return;
    final updated = List<ImportantDate>.of(dates);
    if (index == null) {
      updated.add(result);
    } else {
      updated[index] = result;
    }
    onDatesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final intervals = {0, 7, 14, 30, 60, 90, 180, 365, ?reminder?.intervalDays}.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Garder le lien', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Me rappeler de prendre des nouvelles'),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: reminder?.intervalDays ?? 0,
              isExpanded: true,
              items: [
                for (final days in intervals)
                  DropdownMenuItem(
                    value: days,
                    child: Text(days == 0 ? 'Pas de rappel' : 'Tous les $days jours'),
                  ),
              ],
              onChanged: (days) {
                if (days == null) return;
                onReminderChanged(days == 0 ? null : ContactReminder(
                  intervalDays: days,
                  anchorDate: reminder?.anchorDate ?? DateTime.now(),
                  snoozedUntil: reminder?.snoozedUntil,
                ));
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(reminder == null
          ? 'À votre rythme, sans obligation.'
          : 'Prochaine attention : ${formatContactDate(reminder!.dueDate)}. '
            'Retrouvez-la dans « À penser » en ouvrant le carnet.'),
        const SizedBox(height: 24),
        Text('Les dates qui comptent', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (var index = 0; index < dates.length; index++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(dates[index].title),
            subtitle: Text('${dates[index].day.toString().padLeft(2, '0')}/'
              '${dates[index].month.toString().padLeft(2, '0')} · Chaque année'),
            onTap: () => _editDate(context, index: index),
            trailing: IconButton(
              tooltip: 'Retirer ${dates[index].title}',
              onPressed: () => onDatesChanged([...dates]..removeAt(index)),
              icon: const Icon(Icons.close),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: () => _editDate(context, birthday: true),
              icon: const Icon(Icons.cake_outlined),
              label: const Text('Ajouter un anniversaire'),
            ),
            TextButton.icon(
              onPressed: () => _editDate(context),
              icon: const Icon(Icons.event_outlined),
              label: const Text('Ajouter une autre date'),
            ),
          ],
        ),
        const Text('Le 29 février est célébré le 28 les années non bissextiles.'),
      ],
    );
  }
}

class _DateDialog extends StatefulWidget {
  const _DateDialog({this.initial, this.birthday = false});
  final ImportantDate? initial;
  final bool birthday;

  @override
  State<_DateDialog> createState() => _DateDialogState();
}

class _DateDialogState extends State<_DateDialog> {
  static const _months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.initial?.title ?? (widget.birthday ? 'Anniversaire' : ''),
  );
  late int _month = widget.initial?.month ?? DateTime.now().month;
  late int _day = widget.initial?.day ?? DateTime.now().day;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Une date à retenir'),
    scrollable: true,
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _title,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Ce que l’on célèbre'),
            validator: (value) => value == null || value.trim().isEmpty ? 'Donnez un nom à cette date.' : null,
          ),
          const SizedBox(height: 12),
          const Text('Mois'),
          DropdownButton<int>(
            isExpanded: true,
            value: _month,
            items: [for (var month = 1; month <= 12; month++)
              DropdownMenuItem(value: month, child: Text(_months[month - 1]))],
            onChanged: (month) {
              if (month == null) return;
              setState(() {
                _month = month;
                final lastDay = DateTime(2000, month + 1, 0).day;
                if (_day > lastDay) _day = lastDay;
              });
            },
          ),
          const Text('Jour'),
          DropdownButton<int>(
            isExpanded: true,
            value: _day,
            items: [for (var day = 1; day <= DateTime(2000, _month + 1, 0).day; day++)
              DropdownMenuItem(value: day, child: Text('$day'))],
            onChanged: (day) { if (day != null) setState(() => _day = day); },
          ),
          const Text('Chaque année, sans enregistrer l’année de naissance.'),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, ImportantDate(title: _title.text.trim(), month: _month, day: _day));
          }
        },
        child: const Text('Garder cette date'),
      ),
    ],
  );
}
