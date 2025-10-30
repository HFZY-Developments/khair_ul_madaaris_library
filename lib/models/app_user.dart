/// App User Model for Authentication
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isAdmin;
  final DateTime lastSignIn;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isAdmin = false,
    required this.lastSignIn,
  });

  /// Get initials for avatar
  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '?';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
      'lastSignIn': lastSignIn.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      lastSignIn: json['lastSignIn'] != null
          ? DateTime.parse(json['lastSignIn'] as String)
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAdmin,
    DateTime? lastSignIn,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, displayName: $displayName, isAdmin: $isAdmin}';
  }
}
