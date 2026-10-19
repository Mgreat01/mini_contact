import 'package:flutter/material.dart';
import '../domain/contact_interaction.dart';
import '../domain/relationship_dates.dart';

class InteractionHistory extends StatelessWidget {
  const InteractionHistory({super.key, required this.interactions, this.onRemove});
  final List<ContactInteraction> interactions;
  final ValueChanged<ContactInteraction>? onRemove;

  @override
  Widget build(BuildContext context) {
    final sorted = List.of(interactions)..sort((a, b) => b.date.compareTo(a.date));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final interaction in sorted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 12),
                  child: Icon(Icons.chat_bubble_outline, size: 20),
                ),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatContactDate(interaction.date),
                      style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    SelectableText(interaction.note.isEmpty
                      ? 'Des nouvelles échangées' : interaction.note),
                  ],
                )),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Retirer l’échange du ${formatContactDate(interaction.date)}',
                    onPressed: () => onRemove!(interaction),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class InteractionEditor extends StatefulWidget {
  const InteractionEditor({super.key, required this.onConfirmed});
  final ValueChanged<String> onConfirmed;

  @override
  State<InteractionEditor> createState() => _InteractionEditorState();
}

class _InteractionEditorState extends State<InteractionEditor> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _note,
        maxLength: 500,
        minLines: 2,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Un souvenir de notre échange',
          hintText: 'Un café partagé, une bonne nouvelle…',
          alignLabelWithHint: true,
        ),
      ),
      TextButton.icon(
        onPressed: () {
          widget.onConfirmed(_note.text.trim());
          _note.clear();
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Nous avons échangé aujourd’hui'),
      ),
      const Text('Confirmez uniquement un échange réel, puis enregistrez la fiche.'),
    ],
  );
}
