import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for authentication and profile data.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String role;
  final int sustainabilityScore;
  final double totalCarbonSaved;
  final double totalWasteReduced;
  final int challengesCompleted;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isEmailVerified;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.role = 'user',
    this.sustainabilityScore = 0,
    this.totalCarbonSaved = 0,
    this.totalWasteReduced = 0,
    this.challengesCompleted = 0,
    this.badges = const [],
    required this.createdAt,
    this.lastLogin,
    this.isEmailVerified = false,
  });

  /// Create from Firestore document.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user',
      sustainabilityScore: data['sustainabilityScore'] ?? 0,
      totalCarbonSaved: (data['totalCarbonSaved'] ?? 0).toDouble(),
      totalWasteReduced: (data['totalWasteReduced'] ?? 0).toDouble(),
      challengesCompleted: data['challengesCompleted'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,
    );
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'sustainabilityScore': sustainabilityScore,
      'totalCarbonSaved': totalCarbonSaved,
      'totalWasteReduced': totalWasteReduced,
      'challengesCompleted': challengesCompleted,
      'badges': badges,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Create a copy with updated fields.
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? role,
    int? sustainabilityScore,
    double? totalCarbonSaved,
    double? totalWasteReduced,
    int? challengesCompleted,
    List<String>? badges,
    DateTime? lastLogin,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      totalCarbonSaved: totalCarbonSaved ?? this.totalCarbonSaved,
      totalWasteReduced: totalWasteReduced ?? this.totalWasteReduced,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      badges: badges ?? this.badges,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  bool get isAdmin => role == 'admin';
}
