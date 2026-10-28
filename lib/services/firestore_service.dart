import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/carbon_product_challenge.dart';
import '../models/content_models.dart';

/// Firebase Firestore service with automatic Mock Mode fallback capability.
class FirestoreService {
  final FirebaseFirestore? _db;
  final bool useMock;

  // In-memory data store for Mock Mode
  static final List<UserModel> _mockUsers = [];
  static final List<CarbonRecord> _mockCarbonRecords = [];
  static final List<WasteRecord> _mockWasteRecords = [];
  static final List<ProductModel> _mockProducts = [];
  static final List<ChallengeModel> _mockChallenges = [];
  static final List<ChallengeParticipation> _mockParticipations = [];
  static final List<RecipeModel> _mockRecipes = [];
  static final List<PostModel> _mockPosts = [];
  static final List<CommentModel> _mockComments = [];
  static final List<ArticleModel> _mockArticles = [];
  static final List<CertificationModel> _mockCertifications = [];
  static final List<EnergyTipModel> _mockEnergyTips = [];
  static final List<EcoTravelModel> _mockEcoTravel = [];
  static final List<ContactMessage> _mockContactMessages = [];

  // Stream Controllers for live UI updates
  static final StreamController<List<UserModel>> _usersController = StreamController<List<UserModel>>.broadcast();
  static final StreamController<List<CarbonRecord>> _carbonRecordsController = StreamController<List<CarbonRecord>>.broadcast();
  static final StreamController<List<WasteRecord>> _wasteRecordsController = StreamController<List<WasteRecord>>.broadcast();
  static final StreamController<List<ProductModel>> _productsController = StreamController<List<ProductModel>>.broadcast();
  static final StreamController<List<ChallengeModel>> _challengesController = StreamController<List<ChallengeModel>>.broadcast();
  static final StreamController<List<ChallengeParticipation>> _participationsController = StreamController<List<ChallengeParticipation>>.broadcast();
  static final StreamController<List<RecipeModel>> _recipesController = StreamController<List<RecipeModel>>.broadcast();
  static final StreamController<List<PostModel>> _postsController = StreamController<List<PostModel>>.broadcast();
  static final Map<String, StreamController<List<CommentModel>>> _commentsControllers = {};
  static final StreamController<List<ArticleModel>> _articlesController = StreamController<List<ArticleModel>>.broadcast();
  static final StreamController<List<CertificationModel>> _certificationsController = StreamController<List<CertificationModel>>.broadcast();
  static final StreamController<List<EnergyTipModel>> _energyTipsController = StreamController<List<EnergyTipModel>>.broadcast();
  static final StreamController<List<EcoTravelModel>> _ecoTravelController = StreamController<List<EcoTravelModel>>.broadcast();

  FirestoreService({this.useMock = false})
      : _db = useMock ? null : FirebaseFirestore.instance {
    if (useMock && _mockUsers.isEmpty) {
      _initMockData();
    }
  }

  void _notify<T>(StreamController<List<T>> controller, List<T> list) {
    controller.add(List<T>.from(list));
  }

  void _initMockData() {
    // 1. Add Default Mock User
    _mockUsers.add(UserModel(
      uid: 'mock_uid_123',
      name: 'Eco Champion',
      email: 'eco@champion.com',
      phone: '+1 555-0199',
      role: 'admin',
      sustainabilityScore: 78,
      totalCarbonSaved: 120.4,
      totalWasteReduced: 45.8,
      challengesCompleted: 2,
      badges: ['Green Starter', 'Water Saver'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isEmailVerified: true,
    ));

    // 2. Add Products
    _mockProducts.addAll([
      ProductModel(
        id: 'prod_1',
        name: 'Reusable Stainless Steel Water Bottle',
        description: 'Keep your drinks cold for 24 hours and hot for 12. Ditch single-use plastic bottles forever with this vacuum insulated flask.',
        category: 'Zero Waste Products',
        imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=300&q=80',
        sustainabilityRating: 5.0,
        buyLink: 'https://example.com',
        price: 24.99,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'prod_2',
        name: 'Organic Bamboo Toothbrush Pack',
        description: '100% biodegradable and organic bamboo toothbrushes with charcoal-infused bristles. Pack of 4.',
        category: 'Zero Waste Products',
        imageUrl: 'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=300&q=80',
        sustainabilityRating: 4.5,
        buyLink: 'https://example.com',
        price: 9.99,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'prod_3',
        name: 'Smart Solar Phone Charger',
        description: 'High-efficiency solar panels charge your phone on the go using clean solar energy. Ideal for hiking, camping, and emergencies.',
        category: 'Eco Appliances',
        imageUrl: 'https://images.unsplash.com/photo-1617791160536-598cf32026fb?auto=format&fit=crop&w=300&q=80',
        sustainabilityRating: 4.8,
        buyLink: 'https://example.com',
        price: 49.99,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'prod_4',
        name: 'Organic Cotton Produce Bags',
        description: 'Reusable grocery bags made from organic cotton mesh. Perfect for fruits and vegetables. Washable and durable.',
        category: 'Reusable Products',
        imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=300&q=80',
        sustainabilityRating: 4.7,
        buyLink: 'https://example.com',
        price: 14.99,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'prod_5',
        name: 'High-Efficiency LED Bulbs Pack',
        description: 'Save up to 80% energy compared to traditional incandescent light bulbs. Long-lasting smart LED bulbs.',
        category: 'Eco Appliances',
        imageUrl: 'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?auto=format&fit=crop&w=300&q=80',
        sustainabilityRating: 4.9,
        buyLink: 'https://example.com',
        price: 19.99,
        createdAt: DateTime.now(),
      ),
    ]);

    // 3. Add Challenges
    _mockChallenges.addAll([
      ChallengeModel(
        id: 'chal_1',
        title: 'Plastic Free Week',
        description: 'Avoid buying or using single-use plastic items for 7 days.',
        category: 'Waste',
        durationDays: 7,
        imageUrl: 'https://images.unsplash.com/photo-1548345680-f5475ea5df84?auto=format&fit=crop&w=300&q=80',
        pointsReward: 100,
        badgeName: 'Plastic Destroyer',
        tasks: ['Refuse plastic straws and cups', 'Use reusable shopping bags', 'Avoid bottled beverages', 'Buy bulk foods without plastic packaging'],
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        participants: 1420,
      ),
      ChallengeModel(
        id: 'chal_2',
        title: 'Save Water Challenge',
        description: 'Reduce water consumption at home and practice mindful usage.',
        category: 'Conservation',
        durationDays: 5,
        imageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=300&q=80',
        pointsReward: 80,
        badgeName: 'Water Guardian',
        tasks: ['Limit showers to 5 minutes', 'Turn off tap while brushing teeth', 'Fix any home water leaks', 'Wash dishes with a full tub instead of running water'],
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        participants: 890,
      ),
      ChallengeModel(
        id: 'chal_3',
        title: 'Bicycle Week',
        description: 'Swap your car ride for a bicycle ride whenever possible to reduce vehicle emissions.',
        category: 'Transport',
        durationDays: 7,
        imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=300&q=80',
        pointsReward: 150,
        badgeName: 'Eco Rider',
        tasks: ['Ride bike to work/school', 'Bike for running grocery errands', 'Check tire pressure for efficiency', 'Cycle 15 miles in total'],
        startDate: DateTime.now().subtract(const Duration(days: 4)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        participants: 512,
      ),
      ChallengeModel(
        id: 'chal_4',
        title: 'Zero Waste Kitchen',
        description: 'Minimize kitchen trash by composting and avoiding packaged products.',
        category: 'Cooking',
        durationDays: 10,
        imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?auto=format&fit=crop&w=300&q=80',
        pointsReward: 200,
        badgeName: 'Zero Hero',
        tasks: ['Compost organic kitchen waste', 'Use reusable food wraps', 'Meal plan to avoid food spoilage', 'Refuse pre-packaged meals'],
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        participants: 730,
      ),
    ]);

    // 4. Add Recipes
    _mockRecipes.addAll([
      RecipeModel(
        id: 'rec_1',
        title: 'Plant-Based Avocado Toast',
        description: 'Quick and nutritious avocado toast served on organic sourdough bread with fresh cherry tomatoes.',
        category: 'plant_based',
        imageUrl: 'https://images.unsplash.com/photo-1541532713592-79a0317b6b77?auto=format&fit=crop&w=300&q=80',
        ingredients: ['1 slice organic sourdough bread', '1/2 ripe avocado', '5 cherry tomatoes', '1 tsp olive oil', 'Pinch of sea salt & pepper'],
        instructions: ['Toast the bread until golden brown.', 'Mash avocado in a bowl with olive oil, salt, and pepper.', 'Spread avocado mash over the toast.', 'Top with halved cherry tomatoes and a drizzle of olive oil.'],
        prepTime: 5,
        cookTime: 2,
        servings: 1,
        carbonFootprint: 0.2,
      ),
      RecipeModel(
        id: 'rec_2',
        title: 'Organic Quinoa Medley',
        description: 'A protein-packed salad combining cooked organic quinoa, black beans, corn, and fresh chopped cilantro.',
        category: 'organic',
        imageUrl: 'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?auto=format&fit=crop&w=300&q=80',
        ingredients: ['1 cup organic quinoa', '1 can black beans (rinsed)', '1 cup organic corn kernels', '1 red bell pepper (diced)', 'Fresh cilantro', 'Lemon-herb dressing'],
        instructions: ['Rinse and cook quinoa according to package instructions.', 'Allow quinoa to cool to room temperature.', 'In a large bowl, combine quinoa, black beans, corn, bell pepper, and cilantro.', 'Toss with lemon-herb dressing and serve cold.'],
        prepTime: 10,
        cookTime: 15,
        servings: 4,
        carbonFootprint: 0.4,
      ),
      RecipeModel(
        id: 'rec_3',
        title: 'Low Carbon Lentil Curry',
        description: 'A comforting, warm, and highly sustainable red lentil curry cooked in light coconut milk and spices.',
        category: 'low_carbon',
        imageUrl: 'https://images.unsplash.com/photo-1545093149-618eb3bcfd4d?auto=format&fit=crop&w=300&q=80',
        ingredients: ['1 cup dry red lentils', '1 can light coconut milk', '1 onion (chopped)', '2 cloves garlic (minced)', '1 tbsp curry powder', '2 cups spinach'],
        instructions: ['Sauté onion and garlic in a pot with a splash of water or oil.', 'Add curry powder and stir for 1 minute.', 'Add red lentils and coconut milk, bring to a simmer.', 'Cook for 20 minutes until lentils are soft. Stir in spinach until wilted.'],
        prepTime: 10,
        cookTime: 20,
        servings: 3,
        carbonFootprint: 0.3,
      ),
    ]);

    // 5. Add Articles
    _mockArticles.addAll([
      ArticleModel(
        id: 'art_1',
        title: '10 Ways to Reduce Carbon Footprint',
        content: 'Reducing your carbon footprint is one of the most effective ways to combat climate change. Here are 10 actionable tips you can implement today:\n\n1. Eat less red meat: Red meat production requires vast land and emits high levels of methane.\n2. Switch to public transport or bike: Commuting represents a significant portion of individual emissions.\n3. Turn down the thermostat: Lowering your home temperature by just 1 degree Celsius saves significant heating energy.\n4. Unplug devices: Electrical appliances consume standby power even when turned off.\n5. Buy local produce: Reduces food miles and shipping emissions.\n6. Use energy-efficient appliances: Look for Energy Star certifications.\n7. Reduce, reuse, recycle: Less manufacturing equals lower industrial emissions.\n8. Dry clothes naturally: Ditch the dryer for a clothesline.\n9. Mind your water use: Pumping and heating water uses energy.\n10. Plant trees: Trees act as natural carbon sinks.',
        category: 'Carbon Reduction',
        imageUrl: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=300&q=80',
        authorName: 'Sarah Jenkins',
        readTime: 5,
        tags: ['Carbon', 'Environment', 'Tips'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ArticleModel(
        id: 'art_2',
        title: 'The Beginner\'s Guide to Composting',
        content: 'Composting is the natural process of recycling organic matter, such as leaves and food scraps, into a valuable fertilizer that can enrich soil and plants. Why compost? Organic waste in landfills produces methane, a potent greenhouse gas. Composting avoids this.\n\nTo start: \n- Green ingredients (nitrogen): fruit scraps, vegetable peelings, coffee grounds.\n- Brown ingredients (carbon): dry leaves, cardboard, paper, twigs.\n- Keep it moist: A compost pile should feel like a wrung-out sponge.\n- Turn it regularly: Oxygen helps decompose the items efficiently.',
        category: 'Composting',
        imageUrl: 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=300&q=80',
        authorName: 'Michael Chen',
        readTime: 7,
        tags: ['Compost', 'Zero Waste', 'Soil'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ArticleModel(
        id: 'art_3',
        title: 'Transitioning to a Zero Waste Lifestyle',
        content: 'Zero waste is a set of principles focused on waste prevention that encourages the redesign of resource life cycles so that all products are reused. The goal is for no trash to be sent to landfills, incinerators, or the ocean.\n\nFollow the 5 Rs:\n1. Refuse: Say no to items you don\'t need, like straws and flyers.\n2. Reduce: Limit your purchases and focus on essentials.\n3. Reuse: Swap single-use items for reusable ones (bottles, containers).\n4. Recycle: Properly sorting paper, plastics, and glass.\n5. Rot: Compost organic kitchen scraps.',
        category: 'Zero Waste',
        imageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=300&q=80',
        authorName: 'Emma Watson',
        readTime: 6,
        tags: ['Zero Waste', 'Lifestyle', 'Green'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    // 6. Add Certifications
    _mockCertifications.addAll([
      CertificationModel(
        id: 'cert_1',
        name: 'Energy Star',
        description: 'Energy Star is a program run by the U.S. Environmental Protection Agency (EPA) and U.S. Department of Energy (DOE) that promotes energy efficiency. Products carrying the Energy Star label generally use 20–30% less energy than required by federal standards.',
        logoUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=300&q=80',
        benefits: ['Reduces greenhouse gas emissions', 'Lowers utility energy bills', 'Ensures high quality and performance standards'],
        usage: 'Look for the blue Energy Star logo when purchasing home appliances, televisions, computers, heating/cooling equipment, and light bulbs.',
        category: 'Energy Efficiency',
      ),
      CertificationModel(
        id: 'cert_2',
        name: 'Fair Trade Certified',
        description: 'Fair Trade Certified products ensure that farmers and workers behind the goods were paid fair wages, work in safe conditions, and use sustainable farming practices. In addition, an extra Premium is paid into a communal fund to support local education and healthcare.',
        logoUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=80',
        benefits: ['Guarantees safe working conditions', 'Promotes biodiversity and eco-farming', 'Empowers local community development financially'],
        usage: 'Commonly found on agricultural products such as coffee, tea, chocolate, bananas, cotton clothing, and home goods.',
        category: 'Ethical Trade',
      ),
      CertificationModel(
        id: 'cert_3',
        name: 'USDA Organic',
        description: 'USDA Organic certification verifies that the product is grown and processed according to federal guidelines addressing soil quality, animal raising practices, pest and weed control, and use of additives. Synthetic fertilizers and chemical pesticides are strictly prohibited.',
        logoUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=300&q=80',
        benefits: ['Protects soil health and water ecosystems', 'Minimizes exposure to chemical pesticides', 'Strict ban on Genetically Modified Organisms (GMOs)'],
        usage: 'Mainly found on foods, cosmetics, fresh agricultural produce, and cotton fabrics.',
        category: 'Organic Farming',
      ),
      CertificationModel(
        id: 'cert_4',
        name: 'FSC Certified',
        description: 'The Forest Stewardship Council (FSC) label guarantees that wood and paper products are harvested from responsibly managed forests. This includes protecting local wildlife habitats, respecting indigenous communities, and preventing deforestation.',
        logoUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=300&q=80',
        benefits: ['Ensures zero net deforestation', 'Protects forest biodiversity and water channels', 'Upholds rights of forest laborers and community members'],
        usage: 'Look for the FSC tree-and-checkmark logo on notebooks, paper bags, tissue boxes, furniture, and cardboard packaging.',
        category: 'Forest Conservation',
      ),
      CertificationModel(
        id: 'cert_5',
        name: 'Rainforest Alliance Certified',
        description: 'The Rainforest Alliance green frog seal indicates that an ingredient or product was grown with social, economic, and environmental sustainability principles. Farms undergo rigorous audits protecting forest buffers and local ecosystems.',
        logoUrl: 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?auto=format&fit=crop&w=300&q=80',
        benefits: ['Safeguards tropical forests and wildlife', 'Reduces pesticide use and soil erosion', 'Provides training and financial resilience for farmers'],
        usage: 'Look for the green frog seal on bananas, coffee bags, cocoa/chocolate, tea bags, and paper flowers.',
        category: 'Biodiversity',
      ),
    ]);

    // 7. Add Energy Tips
    _mockEnergyTips.addAll([
      EnergyTipModel(
        id: 'tip_1',
        title: 'Turn Off Standby Power',
        description: 'Unplug electrical appliances or use smart power strips to shut off standby "phantom" power. Chargers, TVs, and microwave clocks draw electricity even when not in active use.',
        category: 'appliances',
        iconUrl: 'power_settings_new',
        potentialSavings: 120.0,
      ),
      EnergyTipModel(
        id: 'tip_2',
        title: 'Install a Programmable Thermostat',
        description: 'Set your thermostat to adjust temperatures automatically when you are sleeping or away from home. Saving energy on unused hours yields large utility bill drops.',
        category: 'home_energy',
        iconUrl: 'thermostat',
        potentialSavings: 150.0,
      ),
      EnergyTipModel(
        id: 'tip_3',
        title: 'Install Smart Water Aerators',
        description: 'Screw low-flow aerators onto your sink faucets. This mixes air into the water stream, maintaining high water pressure while cutting actual water volume in half.',
        category: 'water_conservation',
        iconUrl: 'opacity',
        potentialSavings: 50.0,
      ),
      EnergyTipModel(
        id: 'tip_4',
        title: 'Switch to Solar Path Lights',
        description: 'Replace wired outdoor security lights with solar-powered path and landscape lighting. They store solar energy during the day and turn on automatically at night.',
        category: 'solar',
        iconUrl: 'wb_sunny',
        potentialSavings: 30.0,
      ),
    ]);

    // 8. Add Eco Travel Suggestions
    _mockEcoTravel.addAll([
      EcoTravelModel(
        id: 'trav_1',
        title: 'Green Sanctuary Eco Resort',
        description: 'An eco-lodge constructed with sustainable local materials, utilizing 100% solar power, rainwater collection, and an organic garden restaurant.',
        category: 'hotels',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=300&q=80',
        location: 'Costa Rica',
        ecoRating: 4.9,
        link: 'https://example.com',
      ),
      EcoTravelModel(
        id: 'trav_2',
        title: 'Eco-Minded Carpooling',
        description: 'Share your daily commute with coworkers or neighbors. Eliminating even 1 vehicle trip saves substantial carbon emissions and splits fuel costs.',
        category: 'carpool',
        imageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=300&q=80',
        location: 'Global / Local',
        ecoRating: 4.5,
        link: 'https://example.com',
      ),
      EcoTravelModel(
        id: 'trav_3',
        title: 'City Smart Bike Sharing',
        description: 'Leverage your city\'s public bicycle network. Biking is a zero-emission transport method and helps avoid heavy city traffic blocks.',
        category: 'public_transport',
        imageUrl: 'https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?auto=format&fit=crop&w=300&q=80',
        location: 'Urban Cities',
        ecoRating: 4.8,
        link: 'https://example.com',
      ),
    ]);

    // 9. Add Forum Posts
    _mockPosts.addAll([
      PostModel(
        id: 'post_1',
        userId: 'mock_uid_123',
        userName: 'Eco Champion',
        content: 'Just finished my first Plastic Free Week challenge! Ditching single-use coffee cups and grocery wrappers was challenging, but doing it with friends made it fun. What was your hardest switch?',
        likes: 12,
        likedBy: ['user_x', 'user_y'],
        commentCount: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      PostModel(
        id: 'post_2',
        userId: 'user_a',
        userName: 'GreenLife99',
        content: 'I highly recommend checking out the smart solar phone charger from the suggestions tab. It takes a few hours of direct sunlight, but it charged my phone completely on my hike yesterday! Zero carbon electricity.',
        likes: 8,
        likedBy: ['mock_uid_123'],
        commentCount: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ]);

    // 10. Add Forum Comments
    _mockComments.addAll([
      CommentModel(
        id: 'com_1',
        postId: 'post_1',
        userId: 'user_b',
        userName: 'SustainBabe',
        content: 'Congrats! For me, the hardest switch was trash bags. Finding biodegradable compost bins took a while, but it feels so good now!',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CommentModel(
        id: 'com_2',
        postId: 'post_1',
        userId: 'user_c',
        userName: 'NatureLover',
        content: 'Way to go! I am on day 3 and finding plastic-free shampoo is my current challenge. Any suggestions?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);

    // Join default challenges for the mock user to populate home dashboard challenge status
    _mockParticipations.addAll([
      ChallengeParticipation(
        id: 'part_1',
        userId: 'mock_uid_123',
        challengeId: 'chal_1',
        completedTasks: 2,
        totalTasks: 4,
        isCompleted: false,
        joinedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ChallengeParticipation(
        id: 'part_2',
        userId: 'mock_uid_123',
        challengeId: 'chal_2',
        completedTasks: 4,
        totalTasks: 4,
        isCompleted: true,
        joinedAt: DateTime.now().subtract(const Duration(days: 4)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  // ==================== USER OPERATIONS ====================

  /// Create user document in Firestore.
  Future<void> createUser(UserModel user) async {
    if (useMock) {
      _mockUsers.removeWhere((u) => u.uid == user.uid);
      _mockUsers.add(user);
      _notify(_usersController, _mockUsers);
      return;
    }
    await _db!
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  /// Get user by ID.
  Future<UserModel?> getUser(String uid) async {
    if (useMock) {
      final matches = _mockUsers.where((u) => u.uid == uid);
      if (matches.isNotEmpty) return matches.first;
      
      // If mock user signed in, return a dynamic mock user profile
      final newUser = UserModel(
        uid: uid,
        name: 'Eco Champion',
        email: 'eco@champion.com',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      _mockUsers.add(newUser);
      return newUser;
    }
    final doc =
        await _db!.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  /// Update user data.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (useMock) {
      final index = _mockUsers.indexWhere((u) => u.uid == uid);
      if (index != -index) {
        final existing = _mockUsers[index];
        _mockUsers[index] = existing.copyWith(
          name: data['name'] as String?,
          email: data['email'] as String?,
          phone: data['phone'] as String?,
          photoUrl: data['photoUrl'] as String?,
          role: data['role'] as String?,
          sustainabilityScore: data['sustainabilityScore'] as int?,
          totalCarbonSaved: (data['totalCarbonSaved'] as num?)?.toDouble(),
          totalWasteReduced: (data['totalWasteReduced'] as num?)?.toDouble(),
          challengesCompleted: data['challengesCompleted'] as int?,
          badges: data['badges'] != null ? List<String>.from(data['badges']) : null,
          isEmailVerified: data['isEmailVerified'] as bool?,
        );
        _notify(_usersController, _mockUsers);
      }
      return;
    }
    await _db!
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  /// Get all users (admin).
  Stream<List<UserModel>> getAllUsers() async* {
    if (useMock) {
      yield List<UserModel>.from(_mockUsers);
      yield* _usersController.stream;
    } else {
      yield* _db!.collection(AppConstants.usersCollection).snapshots().map(
            (snapshot) =>
                snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
          );
    }
  }

  /// Delete user (admin).
  Future<void> deleteUser(String uid) async {
    if (useMock) {
      _mockUsers.removeWhere((u) => u.uid == uid);
      _notify(_usersController, _mockUsers);
      return;
    }
    await _db!.collection(AppConstants.usersCollection).doc(uid).delete();
  }

  // ==================== CARBON RECORDS ====================

  /// Add carbon record.
  Future<String> addCarbonRecord(CarbonRecord record) async {
    if (useMock) {
      final newId = 'carbon_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = CarbonRecord(
        id: newId,
        userId: record.userId,
        category: record.category,
        subcategory: record.subcategory,
        amount: record.amount,
        emissions: record.emissions,
        date: record.date,
        notes: record.notes,
      );
      _mockCarbonRecords.add(newRecord);
      _notify(_carbonRecordsController, _mockCarbonRecords);
      
      // Update user sustainability statistics
      final userIndex = _mockUsers.indexWhere((u) => u.uid == record.userId);
      if (userIndex != -1) {
        final existingUser = _mockUsers[userIndex];
        // Deduct/add footprint score impact
        final newCarbonSaved = existingUser.totalCarbonSaved + (10.0 - record.emissions).clamp(0.0, 50.0);
        _mockUsers[userIndex] = existingUser.copyWith(
          totalCarbonSaved: double.parse(newCarbonSaved.toStringAsFixed(1)),
          sustainabilityScore: (existingUser.sustainabilityScore + 2).clamp(0, 100),
        );
        _notify(_usersController, _mockUsers);
      }
      
      return newId;
    }
    final doc = await _db!
        .collection(AppConstants.carbonRecordsCollection)
        .add(record.toFirestore());
    return doc.id;
  }

  /// Get user's carbon records.
  Stream<List<CarbonRecord>> getCarbonRecords(String userId) async* {
    if (useMock) {
      final records = _mockCarbonRecords.where((r) => r.userId == userId).toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      yield records;
      yield* _carbonRecordsController.stream.map((list) {
        final filtered = list.where((r) => r.userId == userId).toList();
        filtered.sort((a, b) => b.date.compareTo(a.date));
        return filtered;
      });
    } else {
      yield* _db!
          .collection(AppConstants.carbonRecordsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CarbonRecord.fromFirestore(doc))
              .toList());
    }
  }

  /// Get carbon records by date range.
  Future<List<CarbonRecord>> getCarbonRecordsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    if (useMock) {
      final records = _mockCarbonRecords.where((r) {
        return r.userId == userId &&
            r.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            r.date.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
      records.sort((a, b) => a.date.compareTo(b.date));
      return records;
    }
    final snapshot = await _db!
        .collection(AppConstants.carbonRecordsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .get();
    return snapshot.docs
        .map((doc) => CarbonRecord.fromFirestore(doc))
        .toList();
  }

  /// Delete carbon record.
  Future<void> deleteCarbonRecord(String recordId) async {
    if (useMock) {
      _mockCarbonRecords.removeWhere((r) => r.id == recordId);
      _notify(_carbonRecordsController, _mockCarbonRecords);
      return;
    }
    await _db!
        .collection(AppConstants.carbonRecordsCollection)
        .doc(recordId)
        .delete();
  }

  // ==================== PRODUCTS ====================

  /// Add product.
  Future<String> addProduct(ProductModel product) async {
    if (useMock) {
      final newId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
      final newProduct = ProductModel(
        id: newId,
        name: product.name,
        description: product.description,
        category: product.category,
        imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=300&q=80',
        sustainabilityRating: product.sustainabilityRating,
        buyLink: product.buyLink,
        price: product.price,
        isActive: product.isActive,
        createdAt: product.createdAt,
      );
      _mockProducts.add(newProduct);
      _notify(_productsController, _mockProducts);
      return newId;
    }
    final doc = await _db!
        .collection(AppConstants.productsCollection)
        .add(product.toFirestore());
    return doc.id;
  }

  /// Get all products.
  Stream<List<ProductModel>> getProducts() async* {
    if (useMock) {
      yield _mockProducts.where((p) => p.isActive).toList();
      yield* _productsController.stream.map((list) => list.where((p) => p.isActive).toList());
    } else {
      yield* _db!
          .collection(AppConstants.productsCollection)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList());
    }
  }

  /// Get products by category.
  Stream<List<ProductModel>> getProductsByCategory(String category) async* {
    if (useMock) {
      yield _mockProducts.where((p) => p.category == category && p.isActive).toList();
      yield* _productsController.stream.map((list) =>
          list.where((p) => p.category == category && p.isActive).toList());
    } else {
      yield* _db!
          .collection(AppConstants.productsCollection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList());
    }
  }

  /// Update product.
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    if (useMock) {
      final index = _mockProducts.indexWhere((p) => p.id == id);
      if (index != -1) {
        final existing = _mockProducts[index];
        _mockProducts[index] = existing.copyWith(
          name: data['name'] as String?,
          description: data['description'] as String?,
          category: data['category'] as String?,
          imageUrl: data['imageUrl'] as String?,
          sustainabilityRating: (data['sustainabilityRating'] as num?)?.toDouble(),
          buyLink: data['buyLink'] as String?,
          price: (data['price'] as num?)?.toDouble(),
          isActive: data['isActive'] as bool?,
        );
        _notify(_productsController, _mockProducts);
      }
      return;
    }
    await _db!
        .collection(AppConstants.productsCollection)
        .doc(id)
        .update(data);
  }

  /// Delete product.
  Future<void> deleteProduct(String id) async {
    if (useMock) {
      _mockProducts.removeWhere((p) => p.id == id);
      _notify(_productsController, _mockProducts);
      return;
    }
    await _db!.collection(AppConstants.productsCollection).doc(id).delete();
  }

  // ==================== CHALLENGES ====================

  /// Add challenge.
  Future<String> addChallenge(ChallengeModel challenge) async {
    if (useMock) {
      final newId = 'chal_${DateTime.now().millisecondsSinceEpoch}';
      final newChallenge = ChallengeModel(
        id: newId,
        title: challenge.title,
        description: challenge.description,
        category: challenge.category,
        durationDays: challenge.durationDays,
        imageUrl: challenge.imageUrl.isNotEmpty ? challenge.imageUrl : 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=300&q=80',
        pointsReward: challenge.pointsReward,
        badgeName: challenge.badgeName,
        tasks: challenge.tasks,
        isActive: challenge.isActive,
        startDate: challenge.startDate,
        endDate: challenge.endDate,
        participants: challenge.participants,
      );
      _mockChallenges.add(newChallenge);
      _notify(_challengesController, _mockChallenges);
      return newId;
    }
    final doc = await _db!
        .collection(AppConstants.challengesCollection)
        .add(challenge.toFirestore());
    return doc.id;
  }

  /// Get all active challenges.
  Stream<List<ChallengeModel>> getChallenges() async* {
    if (useMock) {
      yield _mockChallenges.where((c) => c.isActive).toList();
      yield* _challengesController.stream.map((list) => list.where((c) => c.isActive).toList());
    } else {
      yield* _db!
          .collection(AppConstants.challengesCollection)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ChallengeModel.fromFirestore(doc))
              .toList());
    }
  }

  /// Join a challenge.
  Future<void> joinChallenge(ChallengeParticipation participation) async {
    if (useMock) {
      // Check if already joined
      final exists = _mockParticipations.any((p) =>
          p.userId == participation.userId &&
          p.challengeId == participation.challengeId);
      if (exists) return;

      final newId = 'part_${DateTime.now().millisecondsSinceEpoch}';
      final newPart = ChallengeParticipation(
        id: newId,
        userId: participation.userId,
        challengeId: participation.challengeId,
        completedTasks: 0,
        totalTasks: participation.totalTasks,
        isCompleted: false,
        joinedAt: DateTime.now(),
      );
      _mockParticipations.add(newPart);
      _notify(_participationsController, _mockParticipations);
      return;
    }
    await _db!
        .collection('challenge_participations')
        .add(participation.toFirestore());
  }

  /// Get user's challenge participations.
  Stream<List<ChallengeParticipation>> getUserChallenges(String userId) async* {
    if (useMock) {
      yield _mockParticipations.where((p) => p.userId == userId).toList();
      yield* _participationsController.stream.map((list) =>
          list.where((p) => p.userId == userId).toList());
    } else {
      yield* _db!
          .collection('challenge_participations')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ChallengeParticipation.fromFirestore(doc))
              .toList());
    }
  }

  /// Update challenge progress.
  Future<void> updateChallengeProgress(String participationId, int completedTasks) async {
    if (useMock) {
      final index = _mockParticipations.indexWhere((p) => p.id == participationId);
      if (index != -1) {
        final existing = _mockParticipations[index];
        final total = existing.totalTasks;
        final isCompleted = completedTasks >= total;
        
        final updated = ChallengeParticipation(
          id: existing.id,
          userId: existing.userId,
          challengeId: existing.challengeId,
          completedTasks: completedTasks.clamp(0, total),
          totalTasks: total,
          isCompleted: isCompleted,
          joinedAt: existing.joinedAt,
          completedAt: isCompleted ? DateTime.now() : null,
        );
        _mockParticipations[index] = updated;
        _notify(_participationsController, _mockParticipations);
        
        // Award points if completed
        if (isCompleted && !existing.isCompleted) {
          final challenge = _mockChallenges.firstWhere(
            (c) => c.id == existing.challengeId,
            orElse: () => ChallengeModel(
              title: 'Eco task',
              description: '',
              category: 'General',
              durationDays: 1,
              imageUrl: '',
              pointsReward: 50,
              badgeName: 'Tasker',
              startDate: DateTime.now(),
              endDate: DateTime.now(),
            ),
          );
          
          final userIndex = _mockUsers.indexWhere((u) => u.uid == existing.userId);
          if (userIndex != -1) {
            final user = _mockUsers[userIndex];
            final newBadges = List<String>.from(user.badges);
            if (challenge.badgeName.isNotEmpty && !newBadges.contains(challenge.badgeName)) {
              newBadges.add(challenge.badgeName);
            }
            _mockUsers[userIndex] = user.copyWith(
              challengesCompleted: user.challengesCompleted + 1,
              sustainabilityScore: (user.sustainabilityScore + 10).clamp(0, 100),
              badges: newBadges,
            );
            _notify(_usersController, _mockUsers);
          }
        }
      }
      return;
    }
    await _db!
        .collection('challenge_participations')
        .doc(participationId)
        .update({'completedTasks': completedTasks});
  }

  /// Delete challenge (admin).
  Future<void> deleteChallenge(String id) async {
    if (useMock) {
      _mockChallenges.removeWhere((c) => c.id == id);
      _notify(_challengesController, _mockChallenges);
      return;
    }
    await _db!.collection(AppConstants.challengesCollection).doc(id).delete();
  }

  // ==================== WASTE RECORDS ====================

  /// Add waste record.
  Future<String> addWasteRecord(WasteRecord record) async {
    if (useMock) {
      final newId = 'waste_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = WasteRecord(
        id: newId,
        userId: record.userId,
        category: record.category,
        item: record.item,
        weight: record.weight,
        date: record.date,
        notes: record.notes,
      );
      _mockWasteRecords.add(newRecord);
      _notify(_wasteRecordsController, _mockWasteRecords);
      
      // Update user statistics
      final userIndex = _mockUsers.indexWhere((u) => u.uid == record.userId);
      if (userIndex != -1) {
        final existingUser = _mockUsers[userIndex];
        final newWasteReduced = existingUser.totalWasteReduced + record.weight;
        _mockUsers[userIndex] = existingUser.copyWith(
          totalWasteReduced: double.parse(newWasteReduced.toStringAsFixed(1)),
          sustainabilityScore: (existingUser.sustainabilityScore + 3).clamp(0, 100),
        );
        _notify(_usersController, _mockUsers);
      }
      
      return newId;
    }
    final doc = await _db!
        .collection(AppConstants.wasteRecordsCollection)
        .add(record.toFirestore());
    return doc.id;
  }

  /// Get user's waste records.
  Stream<List<WasteRecord>> getWasteRecords(String userId) async* {
    if (useMock) {
      final records = _mockWasteRecords.where((r) => r.userId == userId).toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      yield records;
      yield* _wasteRecordsController.stream.map((list) {
        final filtered = list.where((r) => r.userId == userId).toList();
        filtered.sort((a, b) => b.date.compareTo(a.date));
        return filtered;
      });
    } else {
      yield* _db!
          .collection(AppConstants.wasteRecordsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => WasteRecord.fromFirestore(doc))
              .toList());
    }
  }

  /// Delete waste record.
  Future<void> deleteWasteRecord(String recordId) async {
    if (useMock) {
      _mockWasteRecords.removeWhere((r) => r.id == recordId);
      _notify(_wasteRecordsController, _mockWasteRecords);
      return;
    }
    await _db!
        .collection(AppConstants.wasteRecordsCollection)
        .doc(recordId)
        .delete();
  }

  // ==================== RECIPES ====================

  /// Add recipe.
  Future<String> addRecipe(RecipeModel recipe) async {
    if (useMock) {
      final newId = 'recipe_${DateTime.now().millisecondsSinceEpoch}';
      final newRecipe = RecipeModel(
        id: newId,
        title: recipe.title,
        description: recipe.description,
        category: recipe.category,
        imageUrl: recipe.imageUrl.isNotEmpty ? recipe.imageUrl : 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=300&q=80',
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        prepTime: recipe.prepTime,
        cookTime: recipe.cookTime,
        servings: recipe.servings,
        carbonFootprint: recipe.carbonFootprint,
        createdAt: DateTime.now(),
      );
      _mockRecipes.add(newRecipe);
      _notify(_recipesController, _mockRecipes);
      return newId;
    }
    final doc = await _db!
        .collection(AppConstants.recipesCollection)
        .add(recipe.toFirestore());
    return doc.id;
  }

  /// Get all recipes.
  Stream<List<RecipeModel>> getRecipes() async* {
    if (useMock) {
      yield _mockRecipes;
      yield* _recipesController.stream;
    } else {
      yield* _db!.collection(AppConstants.recipesCollection).snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => RecipeModel.fromFirestore(doc))
                .toList(),
          );
    }
  }

  /// Get recipes by category.
  Stream<List<RecipeModel>> getRecipesByCategory(String category) async* {
    if (useMock) {
      yield _mockRecipes.where((r) => r.category == category).toList();
      yield* _recipesController.stream.map((list) =>
          list.where((r) => r.category == category).toList());
    } else {
      yield* _db!
          .collection(AppConstants.recipesCollection)
          .where('category', isEqualTo: category)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RecipeModel.fromFirestore(doc))
              .toList());
    }
  }

  /// Delete recipe (admin).
  Future<void> deleteRecipe(String id) async {
    if (useMock) {
      _mockRecipes.removeWhere((r) => r.id == id);
      _notify(_recipesController, _mockRecipes);
      return;
    }
    await _db!.collection(AppConstants.recipesCollection).doc(id).delete();
  }

  // ==================== FORUM POSTS ====================

  /// Create a forum post.
  Future<String> createPost(PostModel post) async {
    if (useMock) {
      final newId = 'post_${DateTime.now().millisecondsSinceEpoch}';
      final newPost = PostModel(
        id: newId,
        userId: post.userId,
        userName: post.userName,
        userPhoto: post.userPhoto,
        content: post.content,
        imageUrl: post.imageUrl,
        likes: 0,
        likedBy: const [],
        commentCount: 0,
        createdAt: DateTime.now(),
      );
      _mockPosts.insert(0, newPost);
      _notify(_postsController, _mockPosts);
      return newId;
    }
    final doc =
        await _db!.collection(AppConstants.postsCollection).add(post.toFirestore());
    return doc.id;
  }

  /// Get all posts.
  Stream<List<PostModel>> getPosts() async* {
    if (useMock) {
      yield _mockPosts;
      yield* _postsController.stream;
    } else {
      yield* _db!
          .collection(AppConstants.postsCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
    }
  }

  /// Like/unlike a post.
  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    if (useMock) {
      final index = _mockPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final existing = _mockPosts[index];
        final listLiked = List<String>.from(existing.likedBy);
        int offset = 0;
        
        if (isLiked) {
          listLiked.remove(userId);
          offset = -1;
        } else {
          listLiked.add(userId);
          offset = 1;
        }
        
        _mockPosts[index] = PostModel(
          id: existing.id,
          userId: existing.userId,
          userName: existing.userName,
          userPhoto: existing.userPhoto,
          content: existing.content,
          imageUrl: existing.imageUrl,
          likes: (existing.likes + offset).clamp(0, 99999),
          likedBy: listLiked,
          commentCount: existing.commentCount,
          createdAt: existing.createdAt,
        );
        _notify(_postsController, _mockPosts);
      }
      return;
    }
    
    final docRef = _db!.collection(AppConstants.postsCollection).doc(postId);
    if (isLiked) {
      await docRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  /// Add comment to a post.
  Future<void> addComment(CommentModel comment) async {
    if (useMock) {
      final newId = 'comment_${DateTime.now().millisecondsSinceEpoch}';
      final newComment = CommentModel(
        id: newId,
        postId: comment.postId,
        userId: comment.userId,
        userName: comment.userName,
        userPhoto: comment.userPhoto,
        content: comment.content,
        createdAt: DateTime.now(),
      );
      _mockComments.insert(0, newComment);
      
      // Update post comment count
      final postIndex = _mockPosts.indexWhere((p) => p.id == comment.postId);
      if (postIndex != -1) {
        final existing = _mockPosts[postIndex];
        _mockPosts[postIndex] = PostModel(
          id: existing.id,
          userId: existing.userId,
          userName: existing.userName,
          userPhoto: existing.userPhoto,
          content: existing.content,
          imageUrl: existing.imageUrl,
          likes: existing.likes,
          likedBy: existing.likedBy,
          commentCount: existing.commentCount + 1,
          createdAt: existing.createdAt,
        );
        _notify(_postsController, _mockPosts);
      }
      
      // Notify comment stream listeners
      if (_commentsControllers.containsKey(comment.postId)) {
        final filtered = _mockComments.where((c) => c.postId == comment.postId).toList();
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _commentsControllers[comment.postId]!.add(filtered);
      }
      
      return;
    }
    await _db!.collection(AppConstants.commentsCollection).add(comment.toFirestore());
    await _db!.collection(AppConstants.postsCollection).doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  /// Get comments for a post.
  Stream<List<CommentModel>> getComments(String postId) async* {
    if (useMock) {
      if (!_commentsControllers.containsKey(postId)) {
        _commentsControllers[postId] = StreamController<List<CommentModel>>.broadcast();
      }
      final comments = _mockComments.where((c) => c.postId == postId).toList();
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      yield comments;
      yield* _commentsControllers[postId]!.stream;
    } else {
      yield* _db!
          .collection(AppConstants.commentsCollection)
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList());
    }
  }

  /// Delete post (admin or owner).
  Future<void> deletePost(String postId) async {
    if (useMock) {
      _mockPosts.removeWhere((p) => p.id == postId);
      _mockComments.removeWhere((c) => c.postId == postId);
      _notify(_postsController, _mockPosts);
      return;
    }
    // Delete all comments for this post
    final comments = await _db!
        .collection(AppConstants.commentsCollection)
        .where('postId', isEqualTo: postId)
        .get();
    for (final comment in comments.docs) {
      await comment.reference.delete();
    }
    await _db!.collection(AppConstants.postsCollection).doc(postId).delete();
  }

  // ==================== ARTICLES ====================

  /// Add article.
  Future<String> addArticle(ArticleModel article) async {
    if (useMock) {
      final newId = 'art_${DateTime.now().millisecondsSinceEpoch}';
      final newArticle = ArticleModel(
        id: newId,
        title: article.title,
        content: article.content,
        category: article.category,
        imageUrl: article.imageUrl.isNotEmpty ? article.imageUrl : 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=300&q=80',
        authorName: article.authorName,
        readTime: article.readTime,
        tags: article.tags,
        createdAt: DateTime.now(),
      );
      _mockArticles.insert(0, newArticle);
      _notify(_articlesController, _mockArticles);
      return newId;
    }
    final doc = await _db!
        .collection(AppConstants.articlesCollection)
        .add(article.toFirestore());
    return doc.id;
  }

  /// Get all articles.
  Stream<List<ArticleModel>> getArticles() async* {
    if (useMock) {
      yield _mockArticles;
      yield* _articlesController.stream;
    } else {
      yield* _db!
          .collection(AppConstants.articlesCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ArticleModel.fromFirestore(doc))
              .toList());
    }
  }

  /// Delete article (admin).
  Future<void> deleteArticle(String id) async {
    if (useMock) {
      _mockArticles.removeWhere((a) => a.id == id);
      _notify(_articlesController, _mockArticles);
      return;
    }
    await _db!.collection(AppConstants.articlesCollection).doc(id).delete();
  }

  // ==================== CERTIFICATIONS ====================

  /// Get all certifications.
  Stream<List<CertificationModel>> getCertifications() async* {
    if (useMock) {
      yield _mockCertifications;
      yield* _certificationsController.stream;
    } else {
      yield* _db!
          .collection(AppConstants.certificationsCollection)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CertificationModel.fromFirestore(doc))
              .toList());
    }
  }

  // ==================== ENERGY TIPS ====================

  /// Get all energy tips.
  Stream<List<EnergyTipModel>> getEnergyTips() async* {
    if (useMock) {
      yield _mockEnergyTips;
      yield* _energyTipsController.stream;
    } else {
      yield* _db!
          .collection(AppConstants.energyTipsCollection)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EnergyTipModel.fromFirestore(doc))
              .toList());
    }
  }

  // ==================== ECO TRAVEL ====================

  /// Get eco travel suggestions.
  Stream<List<EcoTravelModel>> getEcoTravelSuggestions() async* {
    if (useMock) {
      yield _mockEcoTravel;
      yield* _ecoTravelController.stream;
    } else {
      yield* _db!
          .collection(AppConstants.ecoTravelCollection)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EcoTravelModel.fromFirestore(doc))
              .toList());
    }
  }

  // ==================== CONTACT MESSAGES ====================

  /// Submit contact message.
  Future<void> submitContactMessage(ContactMessage message) async {
    if (useMock) {
      _mockContactMessages.add(message);
      return;
    }
    await _db!
        .collection(AppConstants.contactMessagesCollection)
        .add(message.toFirestore());
  }
}
