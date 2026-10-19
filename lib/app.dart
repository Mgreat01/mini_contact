import 'package:flutter/material.dart';
import 'features/contacts/domain/contact_repository.dart';
import 'features/contacts/presentation/contacts_page.dart';
import 'theme.dart';

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key, required this.repository});
  final ContactRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Eli Contacts',
    debugShowCheckedModeBanner: false,
    theme: buildWarmTheme(),
    home: ContactsPage(repository: repository),
  );
}
