import 'package:flutter_test/flutter_test.dart';
import 'package:eli_contacts/features/contacts/domain/contact.dart';
import 'package:eli_contacts/features/contacts/domain/relationship_dates.dart';

void main() {
  test('Un rappel devient dû le jour prévu et repart du dernier échange confirmé', () {
    final reminder = ContactReminder(intervalDays: 30, anchorDate: DateTime(2026, 1, 31, 18));
    expect(reminder.dueDate, DateTime(2026, 3, 2));
    expect(reminder.isDue(DateTime(2026, 3, 1, 23)), isFalse);
    expect(reminder.isDue(DateTime(2026, 3, 2)), isTrue);
    final postponed = reminder.postpone(DateTime(2026, 3, 5));
    expect(postponed.dueDate, DateTime(2026, 3, 12));
    expect(postponed.anchorDate, reminder.anchorDate);
    final confirmed = postponed.confirmContact(DateTime(2026, 3, 6));
    expect(confirmed.dueDate, DateTime(2026, 4, 5));
    expect(confirmed.snoozedUntil, isNull);
  });

  test('Le 29 février devient le 28 en année non bissextile', () {
    const birthday = ImportantDate(title: 'Anniversaire', month: 2, day: 29);
    expect(birthday.nextOccurrence(DateTime(2027, 2, 28, 18)), DateTime(2027, 2, 28));
    expect(birthday.nextOccurrence(DateTime(2027, 3, 1)), DateTime(2028, 2, 29));
    expect(birthday.nextOccurrence(DateTime(2028, 2, 29)), DateTime(2028, 2, 29));
  });

  test('Rappels et dates sont conservés, désactiver ne supprime pas les événements', () {
    final contact = Contact(
      id: '1', name: 'Nadia', phone: '123456789',
      reminder: ContactReminder(intervalDays: 7, anchorDate: DateTime(2026, 10, 19)),
      importantDates: const [ImportantDate(title: 'Anniversaire', month: 12, day: 31)],
    );
    final restored = Contact.fromJson(contact.toJson());
    expect(restored.reminder!.dueDate, DateTime(2026, 10, 26));
    expect(restored.importantDates.single.day, 31);
    expect(restored.copyWith(name: 'Nadia Martin').reminder, isNotNull);
    final disabled = restored.copyWith(clearReminder: true);
    expect(disabled.reminder, isNull);
    expect(disabled.importantDates, hasLength(1));
    expect(Contact.fromJson({'id': 'old', 'name': 'Élie', 'phone': '123456789'}).importantDates, isEmpty);
  });

  test('Les dates corrompues et intervalles invalides sont refusés', () {
    expect(() => ContactReminder(intervalDays: 0, anchorDate: DateTime(2026)), throwsArgumentError);
    expect(() => ImportantDate.fromJson({'title': 'X', 'month': 2, 'day': 31}), throwsFormatException);
    expect(() => ContactReminder.fromJson({'intervalDays': 7, 'anchorDate': '2026-02-31'}), throwsFormatException);
  });
}
