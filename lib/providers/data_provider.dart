import 'package:flutter/material.dart';
import '../models/carbon_product_challenge.dart';
import '../models/content_models.dart';
import '../repositories/data_repository.dart';
import '../core/utils/helpers.dart';

/// Main data provider for all app content modules.
class DataProvider extends ChangeNotifier {
  final DataRepository _repository;

  DataProvider({required DataRepository repository}) : _repository = repository;

  // ==================== CARBON TRACKER STATE ====================
  List<CarbonRecord> _carbonRecords = [];
  bool _carbonLoading = false;

  List<CarbonRecord> get carbonRecords => _carbonRecords;
  bool get carbonLoading => _carbonLoading;

  double get totalEmissions =>
      _carbonRecords.fold(0.0, (sum, r) => sum + r.emissions);

  double get transportEmissions => _carbonRecords
      .where((r) => r.category == 'transport')
      .fold(0.0, (sum, r) => sum + r.emissions);

  double get electricityEmissions => _carbonRecords
      .where((r) => r.category == 'electricity')
      .fold(0.0, (sum, r) => sum + r.emissions);

  double get foodEmissions => _carbonRecords
      .where((r) => r.category == 'food')
      .fold(0.0, (sum, r) => sum + r.emissions);

  double get waterEmissions => _carbonRecords
      .where((r) => r.category == 'water')
      .fold(0.0, (sum, r) => sum + r.emissions);

  int get carbonScore => CarbonCalculator.calculateScore(totalEmissions, 50.0);

  List<String> get suggestions => CarbonCalculator.getSuggestions(
        transportEmissions: transportEmissions,
        electricityEmissions: electricityEmissions,
        foodEmissions: foodEmissions,
        waterEmissions: waterEmissions,
      );

  void listenToCarbonRecords(String userId) {
    _carbonLoading = true;
    notifyListeners();
    _repository.getCarbonRecords(userId).listen((records) {
      _carbonRecords = records;
      _carbonLoading = false;
      notifyListeners();
    });
  }

  Future<void> addCarbonRecord(CarbonRecord record) async {
    await _repository.addCarbonRecord(record);
  }

  Future<void> deleteCarbonRecord(String recordId) async {
    await _repository.deleteCarbonRecord(recordId);
  }

  // ==================== PRODUCTS STATE ====================
  List<ProductModel> _products = [];
  bool _productsLoading = false;
  String _productCategory = 'All';
  String _productSearch = '';

  List<ProductModel> get products => _products;
  bool get productsLoading => _productsLoading;
  String get productCategory => _productCategory;

  List<ProductModel> get filteredProducts {
    var filtered = _products;
    if (_productCategory != 'All') {
      filtered = filtered.where((p) => p.category == _productCategory).toList();
    }
    if (_productSearch.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(_productSearch.toLowerCase()) ||
              p.description
                  .toLowerCase()
                  .contains(_productSearch.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  void listenToProducts() {
    _productsLoading = true;
    notifyListeners();
    _repository.getProducts().listen((products) {
      _products = products;
      _productsLoading = false;
      notifyListeners();
    });
  }

  void setProductCategory(String category) {
    _productCategory = category;
    notifyListeners();
  }

  void searchProducts(String query) {
    _productSearch = query;
    notifyListeners();
  }

  // ==================== CHALLENGES STATE ====================
  List<ChallengeModel> _challenges = [];
  List<ChallengeParticipation> _participations = [];
  bool _challengesLoading = false;

  List<ChallengeModel> get challenges => _challenges;
  List<ChallengeParticipation> get participations => _participations;
  bool get challengesLoading => _challengesLoading;

  int get completedChallenges =>
      _participations.where((p) => p.isCompleted).length;

  void listenToChallenges() {
    _challengesLoading = true;
    notifyListeners();
    _repository.getChallenges().listen((challenges) {
      _challenges = challenges;
      _challengesLoading = false;
      notifyListeners();
    });
  }

  void listenToUserChallenges(String userId) {
    _repository.getUserChallenges(userId).listen((participations) {
      _participations = participations;
      notifyListeners();
    });
  }

  Future<void> joinChallenge(ChallengeParticipation participation) async {
    await _repository.joinChallenge(participation);
  }

  Future<void> updateChallengeProgress(String id, int completed) async {
    await _repository.updateChallengeProgress(id, completed);
  }

  // ==================== WASTE TRACKER STATE ====================
  List<WasteRecord> _wasteRecords = [];
  bool _wasteLoading = false;

  List<WasteRecord> get wasteRecords => _wasteRecords;
  bool get wasteLoading => _wasteLoading;

  double get totalWasteReduced =>
      _wasteRecords.fold(0.0, (sum, r) => sum + r.weight);

  double get recycledWaste => _wasteRecords
      .where((r) => r.category == 'recycled')
      .fold(0.0, (sum, r) => sum + r.weight);

  double get compostedWaste => _wasteRecords
      .where((r) => r.category == 'composting')
      .fold(0.0, (sum, r) => sum + r.weight);

  double get plasticReduced => _wasteRecords
      .where((r) => r.category == 'plastic_reduction')
      .fold(0.0, (sum, r) => sum + r.weight);

  double get paperReduced => _wasteRecords
      .where((r) => r.category == 'paper_reduction')
      .fold(0.0, (sum, r) => sum + r.weight);

  void listenToWasteRecords(String userId) {
    _wasteLoading = true;
    notifyListeners();
    _repository.getWasteRecords(userId).listen((records) {
      _wasteRecords = records;
      _wasteLoading = false;
      notifyListeners();
    });
  }

  Future<void> addWasteRecord(WasteRecord record) async {
    await _repository.addWasteRecord(record);
  }

  Future<void> deleteWasteRecord(String recordId) async {
    await _repository.deleteWasteRecord(recordId);
  }

  // ==================== RECIPES STATE ====================
  List<RecipeModel> _recipes = [];
  List<RecipeModel> _favoriteRecipes = [];
  bool _recipesLoading = false;
  String _recipeCategory = 'All';
  String _recipeSearch = '';

  List<RecipeModel> get recipes => _recipes;
  List<RecipeModel> get favoriteRecipes => _favoriteRecipes;
  bool get recipesLoading => _recipesLoading;
  String get recipeCategory => _recipeCategory;

  List<RecipeModel> get filteredRecipes {
    var filtered = _recipes;
    if (_recipeCategory != 'All') {
      filtered = filtered.where((r) => r.category == _recipeCategory).toList();
    }
    if (_recipeSearch.isNotEmpty) {
      filtered = filtered
          .where((r) =>
              r.title.toLowerCase().contains(_recipeSearch.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  void listenToRecipes() {
    _recipesLoading = true;
    notifyListeners();
    _repository.getRecipes().listen((recipes) {
      _recipes = recipes;
      _recipesLoading = false;
      notifyListeners();
    });
  }

  void setRecipeCategory(String category) {
    _recipeCategory = category;
    notifyListeners();
  }

  void searchRecipes(String query) {
    _recipeSearch = query;
    notifyListeners();
  }

  Future<void> toggleFavoriteRecipe(RecipeModel recipe) async {
    final isFavorite = _favoriteRecipes.any((r) => r.id == recipe.id);
    if (isFavorite) {
      await _repository.removeFavoriteRecipe(recipe.id!);
      _favoriteRecipes.removeWhere((r) => r.id == recipe.id);
    } else {
      await _repository.addFavoriteRecipe(recipe);
      _favoriteRecipes.add(recipe);
    }
    notifyListeners();
  }

  Future<void> loadFavoriteRecipes() async {
    _favoriteRecipes = await _repository.getFavoriteRecipes();
    notifyListeners();
  }

  // ==================== FORUM STATE ====================
  List<PostModel> _posts = [];
  bool _postsLoading = false;

  List<PostModel> get posts => _posts;
  bool get postsLoading => _postsLoading;

  void listenToPosts() {
    _postsLoading = true;
    notifyListeners();
    _repository.getPosts().listen((posts) {
      _posts = posts;
      _postsLoading = false;
      notifyListeners();
    });
  }

  Future<void> createPost(PostModel post) async {
    await _repository.createPost(post);
  }

  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    await _repository.toggleLike(postId, userId, isLiked);
  }

  Future<void> addComment(CommentModel comment) async {
    await _repository.addComment(comment);
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _repository.getComments(postId);
  }

  Future<void> deletePost(String postId) async {
    await _repository.deletePost(postId);
  }

  // ==================== ARTICLES STATE ====================
  List<ArticleModel> _articles = [];
  List<ArticleModel> _bookmarkedArticles = [];
  bool _articlesLoading = false;
  String _articleSearch = '';

  List<ArticleModel> get articles => _articles;
  List<ArticleModel> get bookmarkedArticles => _bookmarkedArticles;
  bool get articlesLoading => _articlesLoading;

  List<ArticleModel> get filteredArticles {
    if (_articleSearch.isEmpty) return _articles;
    return _articles
        .where((a) =>
            a.title.toLowerCase().contains(_articleSearch.toLowerCase()) ||
            a.category.toLowerCase().contains(_articleSearch.toLowerCase()))
        .toList();
  }

  void listenToArticles() {
    _articlesLoading = true;
    notifyListeners();
    _repository.getArticles().listen((articles) {
      _articles = articles;
      _articlesLoading = false;
      notifyListeners();
    });
  }

  void searchArticles(String query) {
    _articleSearch = query;
    notifyListeners();
  }

  Future<void> toggleBookmark(ArticleModel article) async {
    final isBookmarked = _bookmarkedArticles.any((a) => a.id == article.id);
    if (isBookmarked) {
      await _repository.unbookmarkArticle(article.id!);
      _bookmarkedArticles.removeWhere((a) => a.id == article.id);
    } else {
      await _repository.bookmarkArticle(article);
      _bookmarkedArticles.add(article);
    }
    notifyListeners();
  }

  Future<void> loadBookmarkedArticles() async {
    _bookmarkedArticles = await _repository.getBookmarkedArticles();
    notifyListeners();
  }

  // ==================== CERTIFICATIONS STATE ====================
  List<CertificationModel> _certifications = [];

  List<CertificationModel> get certifications => _certifications;

  void listenToCertifications() {
    _repository.getCertifications().listen((certifications) {
      _certifications = certifications;
      notifyListeners();
    });
  }

  // ==================== ENERGY TIPS STATE ====================
  List<EnergyTipModel> _energyTips = [];
  List<EnergyTipModel> _savedTips = [];
  String _tipCategory = 'All';

  List<EnergyTipModel> get energyTips => _energyTips;
  List<EnergyTipModel> get savedTips => _savedTips;

  List<EnergyTipModel> get filteredTips {
    if (_tipCategory == 'All') return _energyTips;
    return _energyTips.where((t) => t.category == _tipCategory).toList();
  }

  void listenToEnergyTips() {
    _repository.getEnergyTips().listen((tips) {
      _energyTips = tips;
      notifyListeners();
    });
  }

  void setTipCategory(String category) {
    _tipCategory = category;
    notifyListeners();
  }

  Future<void> toggleSaveTip(EnergyTipModel tip) async {
    final isSaved = _savedTips.any((t) => t.id == tip.id);
    if (isSaved) {
      await _repository.unsaveTip(tip.id!);
      _savedTips.removeWhere((t) => t.id == tip.id);
    } else {
      await _repository.saveTip(tip);
      _savedTips.add(tip);
    }
    notifyListeners();
  }

  Future<void> loadSavedTips() async {
    _savedTips = await _repository.getSavedTips();
    notifyListeners();
  }

  // ==================== ECO TRAVEL STATE ====================
  List<EcoTravelModel> _ecoTravel = [];
  String _travelCategory = 'All';
  String _travelSearch = '';

  List<EcoTravelModel> get ecoTravel => _ecoTravel;

  List<EcoTravelModel> get filteredTravel {
    var filtered = _ecoTravel;
    if (_travelCategory != 'All') {
      filtered = filtered.where((t) => t.category == _travelCategory).toList();
    }
    if (_travelSearch.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(_travelSearch.toLowerCase()) ||
              t.location.toLowerCase().contains(_travelSearch.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  void listenToEcoTravel() {
    _repository.getEcoTravelSuggestions().listen((travel) {
      _ecoTravel = travel;
      notifyListeners();
    });
  }

  void setTravelCategory(String category) {
    _travelCategory = category;
    notifyListeners();
  }

  void searchTravel(String query) {
    _travelSearch = query;
    notifyListeners();
  }

  // ==================== CONTACT ====================

  Future<void> submitContact(ContactMessage message) async {
    await _repository.submitContactMessage(message);
  }

  // ==================== ADMIN OPERATIONS ====================

  Future<void> addProduct(ProductModel product) async {
    await _repository.addProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
  }

  Future<void> addChallenge(ChallengeModel challenge) async {
    await _repository.addChallenge(challenge);
  }

  Future<void> deleteChallenge(String id) async {
    await _repository.deleteChallenge(id);
  }

  Future<void> addArticle(ArticleModel article) async {
    await _repository.addArticle(article);
  }

  Future<void> deleteArticle(String id) async {
    await _repository.deleteArticle(id);
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    await _repository.addRecipe(recipe);
  }

  Future<void> deleteRecipe(String id) async {
    await _repository.deleteRecipe(id);
  }
}
