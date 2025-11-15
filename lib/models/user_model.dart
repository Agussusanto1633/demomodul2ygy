// ============================================
// USER MODEL
// ============================================
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
    this.lastLogin,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // CopyWith method
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username)';
  }

  // Get display name
  String get displayName => username.isNotEmpty ? username : email.split('@')[0];

  // Get initials for avatar
  String get initials {
    if (username.isEmpty) return '??';
    final parts = username.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, 2).toUpperCase();
  }
}