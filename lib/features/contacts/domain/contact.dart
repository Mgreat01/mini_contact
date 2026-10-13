class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
  });
  final String id;
  final String name;
  final String phone;
  final String email;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
  };
  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String? ?? '',
  );
}
