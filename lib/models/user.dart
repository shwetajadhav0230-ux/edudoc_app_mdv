// Data model for the user profile, replacing the simple Map in AppState

class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? bio;
  final String? profileImageBase64; // Stores image data as a string

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.bio,
    this.profileImageBase64,
  });

  User copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? bio,
    String? profileImageBase64,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
    );
  }
}
