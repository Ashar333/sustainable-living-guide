import 'package:cloud_firestore/cloud_firestore.dart';

/// Waste reduction record model.
class WasteRecord {
  final String? id;
  final String userId;
  final String category; // recycled, composting, plastic_reduction, paper_reduction
  final String item;
  final double weight; // in kg
  final DateTime date;
  final String? notes;

  WasteRecord({
    this.id,
    required this.userId,
    required this.category,
    required this.item,
    required this.weight,
    required this.date,
    this.notes,
  });

  factory WasteRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WasteRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      item: data['item'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'item': item,
      'weight': weight,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }
}

/// Recipe model for sustainable meals.
class RecipeModel {
  final String? id;
  final String title;
  final String description;
  final String category; // plant_based, organic, low_carbon
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTime; // minutes
  final int cookTime; // minutes
  final int servings;
  final double carbonFootprint; // kg CO2 per serving
  final bool isFavorite;
  final DateTime createdAt;

  RecipeModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.ingredients = const [],
    this.instructions = const [],
    this.prepTime = 0,
    this.cookTime = 0,
    this.servings = 1,
    this.carbonFootprint = 0,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      prepTime: data['prepTime'] ?? 0,
      cookTime: data['cookTime'] ?? 0,
      servings: data['servings'] ?? 1,
      carbonFootprint: (data['carbonFootprint'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'carbonFootprint': carbonFootprint,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Forum post model.
class PostModel {
  final String? id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String content;
  final String? imageUrl;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'likedBy': likedBy,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Comment model.
class CommentModel {
  final String? id;
  final String postId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String content;
  final DateTime createdAt;

  CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Article model for educational content.
class ArticleModel {
  final String? id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  final String authorName;
  final int readTime; // minutes
  final List<String> tags;
  final bool isBookmarked;
  final DateTime createdAt;

  ArticleModel({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.authorName,
    this.readTime = 5,
    this.tags = const [],
    this.isBookmarked = false,
    required this.createdAt,
  });

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      authorName: data['authorName'] ?? '',
      readTime: data['readTime'] ?? 5,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'authorName': authorName,
      'readTime': readTime,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Green certification model.
class CertificationModel {
  final String? id;
  final String name;
  final String description;
  final String logoUrl;
  final List<String> benefits;
  final String usage;
  final String category;

  CertificationModel({
    this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    this.benefits = const [],
    required this.usage,
    required this.category,
  });

  factory CertificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CertificationModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      benefits: List<String>.from(data['benefits'] ?? []),
      usage: data['usage'] ?? '',
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'benefits': benefits,
      'usage': usage,
      'category': category,
    };
  }
}

/// Energy conservation tip model.
class EnergyTipModel {
  final String? id;
  final String title;
  final String description;
  final String category; // home_energy, appliances, solar, water_conservation
  final String iconUrl;
  final double potentialSavings; // estimated kWh or liters saved
  final bool isSaved;

  EnergyTipModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.iconUrl = '',
    this.potentialSavings = 0,
    this.isSaved = false,
  });

  factory EnergyTipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EnergyTipModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      potentialSavings: (data['potentialSavings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'iconUrl': iconUrl,
      'potentialSavings': potentialSavings,
    };
  }
}

/// Eco travel suggestion model.
class EcoTravelModel {
  final String? id;
  final String title;
  final String description;
  final String category; // hotels, public_transport, carpool, tips
  final String imageUrl;
  final String location;
  final double ecoRating;
  final String link;

  EcoTravelModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.location = '',
    this.ecoRating = 0,
    this.link = '',
  });

  factory EcoTravelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EcoTravelModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      location: data['location'] ?? '',
      ecoRating: (data['ecoRating'] ?? 0).toDouble(),
      link: data['link'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'location': location,
      'ecoRating': ecoRating,
      'link': link,
    };
  }
}

/// Contact message model.
class ContactMessage {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String message;
  final DateTime createdAt;

  ContactMessage({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.createdAt,
  });

  factory ContactMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactMessage(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
