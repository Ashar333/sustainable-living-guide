import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/carbon_product_challenge.dart';
import '../models/content_models.dart';

/// SQLite service for offline data storage with in-memory Web fallback.
class SQLiteService {
  static Database? _database;
  static const String _dbName = 'sustainable_living.db';
  static const int _dbVersion = 1;

  // In-memory storage for Web platform
  static final List<Map<String, dynamic>> _webCarbonRecords = [];
  static final List<Map<String, dynamic>> _webWasteRecords = [];
  static final List<Map<String, dynamic>> _webBookmarkedArticles = [];
  static final List<Map<String, dynamic>> _webFavoriteRecipes = [];
  static final List<Map<String, dynamic>> _webSavedTips = [];
  static final List<Map<String, dynamic>> _webSyncQueue = [];

  /// Get database instance (non-web only).
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web.');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database (non-web only).
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables (non-web only).
  Future<void> _onCreate(Database db, int version) async {
    // Carbon records table
    await db.execute('''
      CREATE TABLE carbon_records (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT NOT NULL,
        amount REAL NOT NULL,
        emissions REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Waste records table
    await db.execute('''
      CREATE TABLE waste_records (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        category TEXT NOT NULL,
        item TEXT NOT NULL,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Bookmarked articles table
    await db.execute('''
      CREATE TABLE bookmarked_articles (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        imageUrl TEXT,
        authorName TEXT,
        readTime INTEGER,
        createdAt TEXT
      )
    ''');

    // Favorite recipes table
    await db.execute('''
      CREATE TABLE favorite_recipes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        imageUrl TEXT,
        ingredients TEXT,
        instructions TEXT,
        prepTime INTEGER,
        cookTime INTEGER,
        servings INTEGER,
        carbonFootprint REAL
      )
    ''');

    // Saved energy tips table
    await db.execute('''
      CREATE TABLE saved_tips (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        iconUrl TEXT,
        potentialSavings REAL
      )
    ''');

    // Sync queue table for offline changes
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection TEXT NOT NULL,
        operation TEXT NOT NULL,
        documentId TEXT,
        data TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_carbon_user ON carbon_records(userId)');
    await db.execute(
        'CREATE INDEX idx_carbon_date ON carbon_records(date)');
    await db.execute(
        'CREATE INDEX idx_waste_user ON waste_records(userId)');
    await db.execute(
        'CREATE INDEX idx_waste_date ON waste_records(date)');
  }

  /// Handle database upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle schema migrations here
  }

  // ==================== CARBON RECORDS ====================

  /// Insert carbon record locally.
  Future<void> insertCarbonRecord(CarbonRecord record) async {
    final data = {
      'id': record.id ?? '',
      'userId': record.userId,
      'category': record.category,
      'subcategory': record.subcategory,
      'amount': record.amount,
      'emissions': record.emissions,
      'date': record.date.toIso8601String(),
      'notes': record.notes,
    };

    if (kIsWeb) {
      _webCarbonRecords.removeWhere((item) => item['id'] == record.id);
      _webCarbonRecords.add(data);
      return;
    }

    final db = await database;
    await db.insert('carbon_records', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get all carbon records for a user.
  Future<List<CarbonRecord>> getLocalCarbonRecords(String userId) async {
    if (kIsWeb) {
      final filtered = _webCarbonRecords
          .where((map) => map['userId'] == userId)
          .toList();
      // Sort by date DESC
      filtered.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return filtered.map((map) {
        return CarbonRecord(
          id: map['id'] as String,
          userId: map['userId'] as String,
          category: map['category'] as String,
          subcategory: map['subcategory'] as String,
          amount: map['amount'] as double,
          emissions: map['emissions'] as double,
          date: DateTime.parse(map['date'] as String),
          notes: map['notes'] as String?,
        );
      }).toList();
    }

    final db = await database;
    final maps = await db.query(
      'carbon_records',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) {
      return CarbonRecord(
        id: map['id'] as String,
        userId: map['userId'] as String,
        category: map['category'] as String,
        subcategory: map['subcategory'] as String,
        amount: map['amount'] as double,
        emissions: map['emissions'] as double,
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String?,
      );
    }).toList();
  }

  /// Delete local carbon record.
  Future<void> deleteLocalCarbonRecord(String id) async {
    if (kIsWeb) {
      _webCarbonRecords.removeWhere((item) => item['id'] == id);
      return;
    }

    final db = await database;
    await db.delete('carbon_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== WASTE RECORDS ====================

  /// Insert waste record locally.
  Future<void> insertWasteRecord(WasteRecord record) async {
    final data = {
      'id': record.id ?? '',
      'userId': record.userId,
      'category': record.category,
      'item': record.item,
      'weight': record.weight,
      'date': record.date.toIso8601String(),
      'notes': record.notes,
    };

    if (kIsWeb) {
      _webWasteRecords.removeWhere((item) => item['id'] == record.id);
      _webWasteRecords.add(data);
      return;
    }

    final db = await database;
    await db.insert('waste_records', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get all waste records for a user.
  Future<List<WasteRecord>> getLocalWasteRecords(String userId) async {
    if (kIsWeb) {
      final filtered = _webWasteRecords
          .where((map) => map['userId'] == userId)
          .toList();
      filtered.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return filtered.map((map) {
        return WasteRecord(
          id: map['id'] as String,
          userId: map['userId'] as String,
          category: map['category'] as String,
          item: map['item'] as String,
          weight: map['weight'] as double,
          date: DateTime.parse(map['date'] as String),
          notes: map['notes'] as String?,
        );
      }).toList();
    }

    final db = await database;
    final maps = await db.query(
      'waste_records',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) {
      return WasteRecord(
        id: map['id'] as String,
        userId: map['userId'] as String,
        category: map['category'] as String,
        item: map['item'] as String,
        weight: map['weight'] as double,
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String?,
      );
    }).toList();
  }

  // ==================== BOOKMARKED ARTICLES ====================

  /// Bookmark an article.
  Future<void> bookmarkArticle(ArticleModel article) async {
    final data = {
      'id': article.id ?? '',
      'title': article.title,
      'content': article.content,
      'category': article.category,
      'imageUrl': article.imageUrl,
      'authorName': article.authorName,
      'readTime': article.readTime,
      'createdAt': article.createdAt.toIso8601String(),
    };

    if (kIsWeb) {
      _webBookmarkedArticles.removeWhere((item) => item['id'] == article.id);
      _webBookmarkedArticles.add(data);
      return;
    }

    final db = await database;
    await db.insert('bookmarked_articles', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Remove article bookmark.
  Future<void> unbookmarkArticle(String id) async {
    if (kIsWeb) {
      _webBookmarkedArticles.removeWhere((item) => item['id'] == id);
      return;
    }

    final db = await database;
    await db.delete('bookmarked_articles', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all bookmarked articles.
  Future<List<ArticleModel>> getBookmarkedArticles() async {
    if (kIsWeb) {
      return _webBookmarkedArticles.map((map) {
        return ArticleModel(
          id: map['id'] as String,
          title: map['title'] as String,
          content: map['content'] as String,
          category: map['category'] as String,
          imageUrl: map['imageUrl'] as String? ?? '',
          authorName: map['authorName'] as String? ?? '',
          readTime: map['readTime'] as int? ?? 5,
          createdAt: DateTime.parse(map['createdAt'] as String),
          isBookmarked: true,
        );
      }).toList();
    }

    final db = await database;
    final maps = await db.query('bookmarked_articles');
    return maps.map((map) {
      return ArticleModel(
        id: map['id'] as String,
        title: map['title'] as String,
        content: map['content'] as String,
        category: map['category'] as String,
        imageUrl: map['imageUrl'] as String? ?? '',
        authorName: map['authorName'] as String? ?? '',
        readTime: map['readTime'] as int? ?? 5,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isBookmarked: true,
      );
    }).toList();
  }

  /// Check if article is bookmarked.
  Future<bool> isArticleBookmarked(String id) async {
    if (kIsWeb) {
      return _webBookmarkedArticles.any((item) => item['id'] == id);
    }

    final db = await database;
    final result = await db.query('bookmarked_articles',
        where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  // ==================== FAVORITE RECIPES ====================

  /// Add recipe to favorites.
  Future<void> addFavoriteRecipe(RecipeModel recipe) async {
    final data = {
      'id': recipe.id ?? '',
      'title': recipe.title,
      'description': recipe.description,
      'category': recipe.category,
      'imageUrl': recipe.imageUrl,
      'ingredients': recipe.ingredients.join('||'),
      'instructions': recipe.instructions.join('||'),
      'prepTime': recipe.prepTime,
      'cookTime': recipe.cookTime,
      'servings': recipe.servings,
      'carbonFootprint': recipe.carbonFootprint,
    };

    if (kIsWeb) {
      _webFavoriteRecipes.removeWhere((item) => item['id'] == recipe.id);
      _webFavoriteRecipes.add(data);
      return;
    }

    final db = await database;
    await db.insert('favorite_recipes', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Remove recipe from favorites.
  Future<void> removeFavoriteRecipe(String id) async {
    if (kIsWeb) {
      _webFavoriteRecipes.removeWhere((item) => item['id'] == id);
      return;
    }

    final db = await database;
    await db.delete('favorite_recipes', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all favorite recipes.
  Future<List<RecipeModel>> getFavoriteRecipes() async {
    if (kIsWeb) {
      return _webFavoriteRecipes.map((map) {
        return RecipeModel(
          id: map['id'] as String,
          title: map['title'] as String,
          description: map['description'] as String? ?? '',
          category: map['category'] as String? ?? '',
          imageUrl: map['imageUrl'] as String? ?? '',
          ingredients: (map['ingredients'] as String? ?? '').split('||').toList(),
          instructions: (map['instructions'] as String? ?? '').split('||').toList(),
          prepTime: map['prepTime'] as int? ?? 0,
          cookTime: map['cookTime'] as int? ?? 0,
          servings: map['servings'] as int? ?? 1,
          carbonFootprint: (map['carbonFootprint'] as double?) ?? 0,
          isFavorite: true,
        );
      }).toList();
    }

    final db = await database;
    final maps = await db.query('favorite_recipes');
    return maps.map((map) {
      return RecipeModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        category: map['category'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        ingredients:
            (map['ingredients'] as String? ?? '').split('||').toList(),
        instructions:
            (map['instructions'] as String? ?? '').split('||').toList(),
        prepTime: map['prepTime'] as int? ?? 0,
        cookTime: map['cookTime'] as int? ?? 0,
        servings: map['servings'] as int? ?? 1,
        carbonFootprint: (map['carbonFootprint'] as double?) ?? 0,
        isFavorite: true,
      );
    }).toList();
  }

  // ==================== SAVED TIPS ====================

  /// Save an energy tip.
  Future<void> saveTip(EnergyTipModel tip) async {
    final data = {
      'id': tip.id ?? '',
      'title': tip.title,
      'description': tip.description,
      'category': tip.category,
      'iconUrl': tip.iconUrl,
      'potentialSavings': tip.potentialSavings,
    };

    if (kIsWeb) {
      _webSavedTips.removeWhere((item) => item['id'] == tip.id);
      _webSavedTips.add(data);
      return;
    }

    final db = await database;
    await db.insert('saved_tips', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Remove saved tip.
  Future<void> unsaveTip(String id) async {
    if (kIsWeb) {
      _webSavedTips.removeWhere((item) => item['id'] == id);
      return;
    }

    final db = await database;
    await db.delete('saved_tips', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all saved tips.
  Future<List<EnergyTipModel>> getSavedTips() async {
    if (kIsWeb) {
      return _webSavedTips.map((map) {
        return EnergyTipModel(
          id: map['id'] as String,
          title: map['title'] as String,
          description: map['description'] as String,
          category: map['category'] as String,
          iconUrl: map['iconUrl'] as String? ?? '',
          potentialSavings: (map['potentialSavings'] as double?) ?? 0,
          isSaved: true,
        );
      }).toList();
    }

    final db = await database;
    final maps = await db.query('saved_tips');
    return maps.map((map) {
      return EnergyTipModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        category: map['category'] as String,
        iconUrl: map['iconUrl'] as String? ?? '',
        potentialSavings: (map['potentialSavings'] as double?) ?? 0,
        isSaved: true,
      );
    }).toList();
  }

  // ==================== SYNC QUEUE ====================

  /// Add operation to sync queue for offline-first sync.
  Future<void> addToSyncQueue({
    required String collection,
    required String operation,
    String? documentId,
    String? data,
  }) async {
    final record = {
      'collection': collection,
      'operation': operation,
      'documentId': documentId,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (kIsWeb) {
      _webSyncQueue.add(record);
      return;
    }

    final db = await database;
    await db.insert('sync_queue', record);
  }

  /// Get pending sync operations.
  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    if (kIsWeb) {
      return List<Map<String, dynamic>>.from(_webSyncQueue);
    }

    final db = await database;
    return await db.query('sync_queue', orderBy: 'timestamp ASC');
  }

  /// Clear sync queue.
  Future<void> clearSyncQueue() async {
    if (kIsWeb) {
      _webSyncQueue.clear();
      return;
    }

    final db = await database;
    await db.delete('sync_queue');
  }

  /// Clear all local data (on logout).
  Future<void> clearAllData() async {
    if (kIsWeb) {
      _webCarbonRecords.clear();
      _webWasteRecords.clear();
      _webBookmarkedArticles.clear();
      _webFavoriteRecipes.clear();
      _webSavedTips.clear();
      _webSyncQueue.clear();
      return;
    }

    final db = await database;
    await db.delete('carbon_records');
    await db.delete('waste_records');
    await db.delete('bookmarked_articles');
    await db.delete('favorite_recipes');
    await db.delete('saved_tips');
    await db.delete('sync_queue');
  }
}
