import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/domain/relationship_dates.dart';
import 'package:eli_contacts/features/contacts/presentation/attentions_page.dart';

void main() {
  testWidgets('Reporter, confirmer et désactiver préservent les dates personnelles', (tester) async {
    final today = DateTime(2026, 10, 19);
    var contact = Contact(
      id: '1', name: 'Nadia', phone: '123456789',
      reminder: ContactReminder(intervalDays: 7, anchorDate: DateTime(2026, 10, 1)),
      importantDates: const [ImportantDate(title: 'Anniversaire', month: 10, day: 19)],
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: StatefulBuilder(builder: (context, setState) => AttentionsPage(
        contacts: [contact], saving: false, today: today,
        onChanged: (value) => setState(() => contact = value),
        onOpen: (_) {},
      )),
    )));
    await tester.tap(find.text('Reporter de 7 jours'));
    await tester.pumpAndSettle();
    expect(contact.reminder!.dueDate, DateTime(2026, 10, 26));
    await tester.tap(find.text('J’ai pris contact'));
    await tester.pumpAndSettle();
    expect(contact.reminder!.anchorDate, today);
    expect(contact.reminder!.snoozedUntil, isNull);
    await tester.tap(find.text('Désactiver le rappel'));
    await tester.pumpAndSettle();
    expect(contact.reminder, isNull);
    expect(contact.importantDates, hasLength(1));
    expect(find.textContaining('Aujourd’hui'), findsOneWidget);
  });

  testWidgets('Une sauvegarde en cours interdit les actions répétées', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AttentionsPage(
      contacts: [Contact(
        id: '1', name: 'Nadia', phone: '123456789',
        reminder: ContactReminder(intervalDays: 7, anchorDate: DateTime(2026, 10, 1)),
      )],
      saving: true, today: DateTime(2026, 10, 19),
      onChanged: (_) => calls++, onOpen: (_) {},
    ))));
    await tester.tap(find.text('J’ai pris contact'));
    expect(calls, 0);
  });
}
