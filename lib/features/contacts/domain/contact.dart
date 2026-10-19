class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.meetingContext = '',
    this.notes = '',
  });
  final String id;
  final String name;
  final String phone;
  final String email;
  final String meetingContext;
  final String notes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'meetingContext': meetingContext,
    'notes': notes,
  };
  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String? ?? '',
    meetingContext: json['meetingContext'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
  );
}
