import 'package:flutter_test/flutter_test.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/domain/relationship_dates.dart';

void main() {
  test('Confirmer un échange conserve un souvenir et recalcule le rappel', () {
    final original = Contact(
      id: '1', name: 'Nadia', phone: '123456789', circles: const ['Amis'],
      reminder: ContactReminder(intervalDays: 30, anchorDate: DateTime(2026, 9, 1)),
    );
    final confirmed = original.confirmContact(DateTime(2026, 10, 19), note: 'Un café partagé');
    expect(original.interactions, isEmpty);
    final restored = Contact.fromJson(confirmed.toJson());
    expect(restored.interactions.single.date, DateTime(2026, 10, 19));
    expect(restored.interactions.single.note, 'Un café partagé');
    expect(restored.reminder!.dueDate, DateTime(2026, 11, 18));
    expect(restored.copyWith(clearReminder: true).interactions, hasLength(1));
    expect(restored.circles, ['Amis']);
  });

  test('Un échange peut être conservé sans activer de rappel', () {
    const original = Contact(id: '1', name: 'Nadia', phone: '123456789');
    final updated = original.confirmContact(DateTime(2026, 10, 19));
    expect(updated.reminder, isNull);
    expect(updated.interactions, hasLength(1));
  });
}
