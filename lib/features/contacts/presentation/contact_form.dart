import 'package:flutter/material.dart';
import '../domain/contact.dart';
import 'label_picker.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key, this.contact});
  final Contact? contact;
  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.contact?.name);
  late final _phone = TextEditingController(text: widget.contact?.phone);
  late final _email = TextEditingController(text: widget.contact?.email);
  late final _meetingContext = TextEditingController(
    text: widget.contact?.meetingContext,
  );
  late final _notes = TextEditingController(text: widget.contact?.notes);
  late List<String> _circles = List.of(widget.contact?.circles ?? []);
  late List<String> _tags = List.of(widget.contact?.tags ?? []);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _meetingContext.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      (widget.contact ?? Contact(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: '',
        phone: '',
      )).copyWith(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        meetingContext: _meetingContext.text.trim(),
        notes: _notes.text.trim(),
        circles: _circles,
        tags: _tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.contact == null ? 'Nouveau contact' : 'Modifier le contact',
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _key,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nom complet *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Saisissez un nom.'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Téléphone *',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (!RegExp(r'^\+?[0-9\s().-]+$').hasMatch(phone) ||
                      phone.replaceAll(RegExp(r'\D'), '').length < 6) {
                    return 'Saisissez un numéro valide (au moins 6 chiffres).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Adresse e-mail (facultatif)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) =>
                    value != null &&
                        value.trim().isNotEmpty &&
                        !RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(value.trim())
                    ? 'Saisissez une adresse e-mail valide.'
                    : null,
              ),
              const SizedBox(height: 28),
              Text(
                'Une personne, une histoire',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Quelques mots pour vous souvenir de ce qui vous rapproche. '
                'Ces informations sont facultatives.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _meetingContext,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notre rencontre',
                  hintText: 'À l’atelier de cuisine, en juin…',
                  prefixIcon: Icon(Icons.waving_hand_outlined),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notes,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Ce que je veux retenir',
                  hintText: 'Ses passions, un souvenir partagé…',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              LabelPicker(
                title: 'Ses cercles',
                inputLabel: 'Nouveau cercle',
                selected: _circles,
                suggestions: const ['Famille', 'Amis', 'Travail'],
                onChanged: (value) => setState(() => _circles = value),
              ),
              const SizedBox(height: 20),
              LabelPicker(
                title: 'Mes repères',
                inputLabel: 'Nouveau tag',
                selected: _tags,
                onChanged: (value) => setState(() => _tags = value),
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.check),
        label: const Text('Enregistrer'),
      ),
    ),
  );
}
