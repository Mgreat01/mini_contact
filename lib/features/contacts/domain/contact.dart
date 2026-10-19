import 'relationship_dates.dart';

class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.meetingContext = '',
    this.notes = '',
    this.circles = const [],
    this.tags = const [],
    this.reminder,
    this.importantDates = const [],
  });
  final String id;
  final String name;
  final String phone;
  final String email;
  final String meetingContext;
  final String notes;
  final List<String> circles;
  final List<String> tags;
  final ContactReminder? reminder;
  final List<ImportantDate> importantDates;

  Contact copyWith({
    String? name,
    String? phone,
    String? email,
    String? meetingContext,
    String? notes,
    List<String>? circles,
    List<String>? tags,
    ContactReminder? reminder,
    bool clearReminder = false,
    List<ImportantDate>? importantDates,
  }) => Contact(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    meetingContext: meetingContext ?? this.meetingContext,
    notes: notes ?? this.notes,
    circles: List.unmodifiable(circles ?? this.circles),
    tags: List.unmodifiable(tags ?? this.tags),
    reminder: clearReminder ? null : (reminder ?? this.reminder),
    importantDates: List.unmodifiable(importantDates ?? this.importantDates),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'meetingContext': meetingContext,
    'notes': notes,
    'circles': circles,
    'tags': tags,
    if (reminder != null) 'reminder': reminder!.toJson(),
    'importantDates': importantDates.map((date) => date.toJson()).toList(),
  };
  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String? ?? '',
    meetingContext: json['meetingContext'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    circles: List.unmodifiable((json['circles'] as List<dynamic>? ?? []).cast<String>()),
    tags: List.unmodifiable((json['tags'] as List<dynamic>? ?? []).cast<String>()),
    reminder: json['reminder'] == null ? null : ContactReminder.fromJson(
      json['reminder'] as Map<String, dynamic>,
    ),
    importantDates: List.unmodifiable((json['importantDates'] as List<dynamic>? ?? [])
      .map((date) => ImportantDate.fromJson(date as Map<String, dynamic>))),
  );
}
