// lib/models/user.dart

class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      // Matches 'Full_name' or 'full_name' from DB
      fullName: map['full_name'] ?? map['Full_name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_num'] ?? '',
      // Matches 'profile_image_url' from DB
      profileImageUrl: map['profile_image_url'] ?? map['avatar_url'],
    );
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}