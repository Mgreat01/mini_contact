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
  });
  final String id;
  final String name;
  final String phone;
  final String email;
  final String meetingContext;
  final String notes;
  final List<String> circles;
  final List<String> tags;

  Contact copyWith({
    String? name,
    String? phone,
    String? email,
    String? meetingContext,
    String? notes,
    List<String>? circles,
    List<String>? tags,
  }) => Contact(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    meetingContext: meetingContext ?? this.meetingContext,
    notes: notes ?? this.notes,
    circles: List.unmodifiable(circles ?? this.circles),
    tags: List.unmodifiable(tags ?? this.tags),
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
  );
}
