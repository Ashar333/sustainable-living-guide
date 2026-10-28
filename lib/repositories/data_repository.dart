import '../models/carbon_product_challenge.dart';
import '../models/content_models.dart';
import '../services/firestore_service.dart';
import '../services/sqlite_service.dart';

/// Main data repository bridging Firestore and SQLite services.
class DataRepository {
  final FirestoreService _firestore;
  final SQLiteService _sqlite;

  DataRepository({
    required FirestoreService firestore,
    required SQLiteService sqlite,
  })  : _firestore = firestore,
        _sqlite = sqlite;

  // ==================== CARBON TRACKER ====================

  Future<String> addCarbonRecord(CarbonRecord record) async {
    await _sqlite.insertCarbonRecord(record);
    return await _firestore.addCarbonRecord(record);
  }

  Stream<List<CarbonRecord>> getCarbonRecords(String userId) {
    return _firestore.getCarbonRecords(userId);
  }

  Future<List<CarbonRecord>> getCarbonRecordsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return _firestore.getCarbonRecordsByDateRange(userId, start, end);
  }

  Future<void> deleteCarbonRecord(String recordId) async {
    await _sqlite.deleteLocalCarbonRecord(recordId);
    await _firestore.deleteCarbonRecord(recordId);
  }

  // ==================== PRODUCTS ====================

  Stream<List<ProductModel>> getProducts() => _firestore.getProducts();

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore.getProductsByCategory(category);
  }

  // ==================== CHALLENGES ====================

  Stream<List<ChallengeModel>> getChallenges() => _firestore.getChallenges();

  Future<void> joinChallenge(ChallengeParticipation participation) {
    return _firestore.joinChallenge(participation);
  }

  Stream<List<ChallengeParticipation>> getUserChallenges(String userId) {
    return _firestore.getUserChallenges(userId);
  }

  Future<void> updateChallengeProgress(String participationId, int completedTasks) {
    return _firestore.updateChallengeProgress(participationId, completedTasks);
  }

  // ==================== WASTE TRACKER ====================

  Future<String> addWasteRecord(WasteRecord record) async {
    await _sqlite.insertWasteRecord(record);
    return await _firestore.addWasteRecord(record);
  }

  Stream<List<WasteRecord>> getWasteRecords(String userId) {
    return _firestore.getWasteRecords(userId);
  }

  Future<void> deleteWasteRecord(String recordId) {
    return _firestore.deleteWasteRecord(recordId);
  }

  // ==================== RECIPES ====================

  Stream<List<RecipeModel>> getRecipes() => _firestore.getRecipes();

  Stream<List<RecipeModel>> getRecipesByCategory(String category) {
    return _firestore.getRecipesByCategory(category);
  }

  Future<void> addFavoriteRecipe(RecipeModel recipe) {
    return _sqlite.addFavoriteRecipe(recipe);
  }

  Future<void> removeFavoriteRecipe(String id) {
    return _sqlite.removeFavoriteRecipe(id);
  }

  Future<List<RecipeModel>> getFavoriteRecipes() {
    return _sqlite.getFavoriteRecipes();
  }

  // ==================== FORUM ====================

  Future<String> createPost(PostModel post) => _firestore.createPost(post);

  Stream<List<PostModel>> getPosts() => _firestore.getPosts();

  Future<void> toggleLike(String postId, String userId, bool isLiked) {
    return _firestore.toggleLike(postId, userId, isLiked);
  }

  Future<void> addComment(CommentModel comment) {
    return _firestore.addComment(comment);
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore.getComments(postId);
  }

  Future<void> deletePost(String postId) => _firestore.deletePost(postId);

  // ==================== ARTICLES ====================

  Stream<List<ArticleModel>> getArticles() => _firestore.getArticles();

  Future<void> bookmarkArticle(ArticleModel article) {
    return _sqlite.bookmarkArticle(article);
  }

  Future<void> unbookmarkArticle(String id) {
    return _sqlite.unbookmarkArticle(id);
  }

  Future<List<ArticleModel>> getBookmarkedArticles() {
    return _sqlite.getBookmarkedArticles();
  }

  Future<bool> isArticleBookmarked(String id) {
    return _sqlite.isArticleBookmarked(id);
  }

  // ==================== CERTIFICATIONS ====================

  Stream<List<CertificationModel>> getCertifications() {
    return _firestore.getCertifications();
  }

  // ==================== ENERGY TIPS ====================

  Stream<List<EnergyTipModel>> getEnergyTips() => _firestore.getEnergyTips();

  Future<void> saveTip(EnergyTipModel tip) => _sqlite.saveTip(tip);

  Future<void> unsaveTip(String id) => _sqlite.unsaveTip(id);

  Future<List<EnergyTipModel>> getSavedTips() => _sqlite.getSavedTips();

  // ==================== ECO TRAVEL ====================

  Stream<List<EcoTravelModel>> getEcoTravelSuggestions() {
    return _firestore.getEcoTravelSuggestions();
  }

  // ==================== CONTACT ====================

  Future<void> submitContactMessage(ContactMessage message) {
    return _firestore.submitContactMessage(message);
  }

  // ==================== ADMIN ====================

  Future<String> addProduct(ProductModel product) {
    return _firestore.addProduct(product);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _firestore.updateProduct(id, data);
  }

  Future<void> deleteProduct(String id) => _firestore.deleteProduct(id);

  Future<String> addChallenge(ChallengeModel challenge) {
    return _firestore.addChallenge(challenge);
  }

  Future<void> deleteChallenge(String id) => _firestore.deleteChallenge(id);

  Future<String> addArticle(ArticleModel article) {
    return _firestore.addArticle(article);
  }

  Future<void> deleteArticle(String id) => _firestore.deleteArticle(id);

  Future<String> addRecipe(RecipeModel recipe) {
    return _firestore.addRecipe(recipe);
  }

  Future<void> deleteRecipe(String id) => _firestore.deleteRecipe(id);

  Stream getAllUsers() => _firestore.getAllUsers();

  Future<void> deleteUser(String uid) => _firestore.deleteUser(uid);
}
