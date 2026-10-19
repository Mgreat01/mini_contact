import 'package:flutter/material.dart';
import '../domain/contact.dart';
import '../domain/contact_search.dart';

Future<(String?, String?)?> showContactFilters(
  BuildContext context, {
  required List<Contact> contacts,
  String? circle,
  String? tag,
}) {
  List<String> labels(Iterable<String> values) {
    final unique = <String, String>{};
    for (final value in values) {
      unique.putIfAbsent(normalizeContactText(value), () => value);
    }
    return unique.values.toList()..sort((a, b) =>
      normalizeContactText(a).compareTo(normalizeContactText(b)));
  }

  final circles = labels(contacts.expand((contact) => contact.circles));
  final tags = labels(contacts.expand((contact) => contact.tags));
  var selectedCircle = circle;
  var selectedTag = tag;
  final choices = [
    for (final value in circles) (true, value),
    for (final value in tags) (false, value),
  ];
  return showModalBottomSheet<(String?, String?)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Retrouver ses proches',
                  style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: choices.isEmpty
                  ? const Center(child: Text('Ajoutez des cercles ou des tags dans une fiche.'))
                  : ListView.builder(
                    itemCount: choices.length,
                    itemBuilder: (context, index) {
                      final (isCircle, label) = choices[index];
                      final selected = isCircle ? selectedCircle : selectedTag;
                      return CheckboxListTile(
                        title: Text(label),
                        subtitle: Text(isCircle ? 'Cercle' : 'Tag'),
                        value: selected != null && normalizeContactText(selected) == normalizeContactText(label),
                        onChanged: (checked) => setState(() {
                          if (isCircle) {
                            selectedCircle = checked == true ? label : null;
                          } else {
                            selectedTag = checked == true ? label : null;
                          }
                        }),
                      );
                    },
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, (null, null)),
                      child: const Text('Effacer les filtres'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, (selectedCircle, selectedTag)),
                      child: const Text('Afficher les contacts'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
