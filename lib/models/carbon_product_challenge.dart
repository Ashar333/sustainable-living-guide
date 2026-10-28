import 'package:cloud_firestore/cloud_firestore.dart';

/// Carbon footprint record model.
class CarbonRecord {
  final String? id;
  final String userId;
  final String category; // transport, electricity, food, water
  final String subcategory; // car, bus, beef, etc.
  final double amount; // quantity (km, kWh, kg, liters)
  final double emissions; // kg CO2
  final DateTime date;
  final String? notes;

  CarbonRecord({
    this.id,
    required this.userId,
    required this.category,
    required this.subcategory,
    required this.amount,
    required this.emissions,
    required this.date,
    this.notes,
  });

  factory CarbonRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarbonRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      emissions: (data['emissions'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'subcategory': subcategory,
      'amount': amount,
      'emissions': emissions,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }
}

/// Eco-friendly product model.
class ProductModel {
  final String? id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double sustainabilityRating;
  final String buyLink;
  final double price;
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.sustainabilityRating,
    required this.buyLink,
    this.price = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sustainabilityRating: (data['sustainabilityRating'] ?? 0).toDouble(),
      buyLink: data['buyLink'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'sustainabilityRating': sustainabilityRating,
      'buyLink': buyLink,
      'price': price,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ProductModel copyWith({
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    double? sustainabilityRating,
    String? buyLink,
    double? price,
    bool? isActive,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sustainabilityRating: sustainabilityRating ?? this.sustainabilityRating,
      buyLink: buyLink ?? this.buyLink,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

/// Challenge model for eco-friendly challenges.
class ChallengeModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final int durationDays;
  final String imageUrl;
  final int pointsReward;
  final String badgeName;
  final List<String> tasks;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final int participants;

  ChallengeModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.imageUrl,
    required this.pointsReward,
    required this.badgeName,
    this.tasks = const [],
    this.isActive = true,
    required this.startDate,
    required this.endDate,
    this.participants = 0,
  });

  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      durationDays: data['durationDays'] ?? 7,
      imageUrl: data['imageUrl'] ?? '',
      pointsReward: data['pointsReward'] ?? 100,
      badgeName: data['badgeName'] ?? '',
      tasks: List<String>.from(data['tasks'] ?? []),
      isActive: data['isActive'] ?? true,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: data['participants'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'durationDays': durationDays,
      'imageUrl': imageUrl,
      'pointsReward': pointsReward,
      'badgeName': badgeName,
      'tasks': tasks,
      'isActive': isActive,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participants': participants,
    };
  }
}

/// User's challenge participation.
class ChallengeParticipation {
  final String? id;
  final String userId;
  final String challengeId;
  final int completedTasks;
  final int totalTasks;
  final bool isCompleted;
  final DateTime joinedAt;
  final DateTime? completedAt;

  ChallengeParticipation({
    this.id,
    required this.userId,
    required this.challengeId,
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.isCompleted = false,
    required this.joinedAt,
    this.completedAt,
  });

  double get progress =>
      totalTasks > 0 ? completedTasks / totalTasks : 0;

  factory ChallengeParticipation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeParticipation(
      id: doc.id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      completedTasks: data['completedTasks'] ?? 0,
      totalTasks: data['totalTasks'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'isCompleted': isCompleted,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
