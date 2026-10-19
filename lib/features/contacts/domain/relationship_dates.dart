/// Calendar dates use local midnight, rather than elapsed 24-hour durations.
DateTime localDay(DateTime value) => DateTime(value.year, value.month, value.day);

String formatContactDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

class ContactReminder {
  ContactReminder({
    required this.intervalDays,
    required DateTime anchorDate,
    DateTime? snoozedUntil,
  }) : anchorDate = localDay(anchorDate),
       snoozedUntil = snoozedUntil == null ? null : localDay(snoozedUntil) {
    if (intervalDays < 1 || intervalDays > 3660) {
      throw ArgumentError.value(intervalDays, 'intervalDays');
    }
  }

  final int intervalDays;
  final DateTime anchorDate;
  final DateTime? snoozedUntil;

  DateTime get dueDate {
    final regular = DateTime(anchorDate.year, anchorDate.month, anchorDate.day + intervalDays);
    final snooze = snoozedUntil;
    return snooze != null && snooze.isAfter(regular) ? snooze : regular;
  }

  bool isDue(DateTime now) => !dueDate.isAfter(localDay(now));

  ContactReminder confirmContact(DateTime now) => ContactReminder(
    intervalDays: intervalDays, anchorDate: now,
  );

  ContactReminder postpone(DateTime now, {int days = 7}) {
    if (days < 1) throw ArgumentError.value(days, 'days');
    final today = localDay(now);
    final start = dueDate.isAfter(today) ? dueDate : today;
    return ContactReminder(
      intervalDays: intervalDays,
      anchorDate: anchorDate,
      snoozedUntil: DateTime(start.year, start.month, start.day + days),
    );
  }

  Map<String, dynamic> toJson() => {
    'intervalDays': intervalDays,
    'anchorDate': _encodeDay(anchorDate),
    if (snoozedUntil != null) 'snoozedUntil': _encodeDay(snoozedUntil!),
  };

  factory ContactReminder.fromJson(Map<String, dynamic> json) => ContactReminder(
    intervalDays: json['intervalDays'] as int,
    anchorDate: _decodeDay(json['anchorDate'] as String),
    snoozedUntil: json['snoozedUntil'] == null ? null : _decodeDay(json['snoozedUntil'] as String),
  );
}

class ImportantDate {
  const ImportantDate({required this.title, required this.month, required this.day})
    : assert(month >= 1 && month <= 12),
      assert(day >= 1 && day <= 31),
      assert(month != 2 || day <= 29),
      assert((month != 4 && month != 6 && month != 9 && month != 11) || day <= 30);

  final String title;
  final int month;
  final int day;

  /// A February 29 occasion falls on February 28 in non-leap years.
  DateTime nextOccurrence(DateTime now) {
    DateTime inYear(int year) {
      final lastDay = DateTime(year, month + 1, 0).day;
      return DateTime(year, month, day > lastDay ? lastDay : day);
    }
    final current = inYear(now.year);
    return current.isBefore(localDay(now)) ? inYear(now.year + 1) : current;
  }

  Map<String, dynamic> toJson() => {'title': title, 'month': month, 'day': day};

  factory ImportantDate.fromJson(Map<String, dynamic> json) {
    final month = json['month'] as int;
    final day = json['day'] as int;
    final date = DateTime(2000, month, day);
    if (date.month != month || date.day != day) {
      throw const FormatException('Date personnelle invalide.');
    }
    return ImportantDate(title: json['title'] as String, month: month, day: day);
  }
}

String _encodeDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime _decodeDay(String value) {
  final date = DateTime.parse(value);
  if (_encodeDay(date) != value) throw const FormatException('Jour invalide.');
  return localDay(date);
}
