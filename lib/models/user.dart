// lib/models/user.dart

class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bio;
  final String? profileImageBase64; // Nullable if not set

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.bio,
    this.profileImageBase64,
  });

  // Factory to create User from Supabase/Map data
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '', // Note snake_case from DB
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      bio: map['bio'] ?? '',
      profileImageBase64: map['profile_image'],
    );
  }

  // Helper to update specific fields (used in Edit Profile)
  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? bio,
    String? profileImageBase64,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
    );
  }
}