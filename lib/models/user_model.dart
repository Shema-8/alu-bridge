import 'package:cloud_firestore/cloud_firestore.dart';

/// Role enum — drives almost every branching decision in the app
/// (which dashboard to show, which profile fields to collect, etc.)
enum UserRole { student, startup }

UserRole roleFromString(String value) =>
    value == 'startup' ? UserRole.startup : UserRole.student;

String roleToString(UserRole role) =>
    role == UserRole.startup ? 'startup' : 'student';

/// Represents a single document in the `users` collection.
///
/// WHY one UserModel for both roles instead of two separate models?
/// Firebase Auth gives us one uid regardless of role, and both roles
/// share core fields (name, email, photo). Role-specific fields
/// (skills vs. companyName) are nullable here and the *startup-specific*
/// detail lives in its own `startups` collection keyed by the same uid.
/// This keeps `users` lightweight and fast to read on every screen,
/// while heavier role-specific data is fetched only when needed.
class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final bool onboardingComplete;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.onboardingComplete = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: roleFromString(map['role'] ?? 'student'),
      photoUrl: map['photoUrl'],
      onboardingComplete: map['onboardingComplete'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': roleToString(role),
      'photoUrl': photoUrl,
      'onboardingComplete': onboardingComplete,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    bool? onboardingComplete,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt,
    );
  }
}
