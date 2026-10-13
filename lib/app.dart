import 'package:flutter/material.dart';
import 'features/contacts/domain/contact_repository.dart';
import 'features/contacts/presentation/contacts_page.dart';

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key, required this.repository});
  final ContactRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Eli Contacts',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315DA8)),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: ContactsPage(repository: repository),
  );
}
