import 'relationship_dates.dart';

/// An exchange explicitly recorded by the user, never inferred from device activity.
class ContactInteraction {
  ContactInteraction({required DateTime date, this.note = ''}) : date = localDay(date);

  final DateTime date;
  final String note;

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'note': note};

  factory ContactInteraction.fromJson(Map<String, dynamic> json) => ContactInteraction(
    date: DateTime.parse(json['date'] as String),
    note: json['note'] as String? ?? '',
  );
}
