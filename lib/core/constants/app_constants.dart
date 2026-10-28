/// Application-wide constants for the Sustainable Living Guide app.
class AppConstants {
  // App Info
  static const String appName = 'Sustainable Living Guide';
  static const String appVersion = '1.0.0';

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String challengesCollection = 'challenges';
  static const String recipesCollection = 'recipes';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String articlesCollection = 'articles';
  static const String carbonRecordsCollection = 'carbon_records';
  static const String wasteRecordsCollection = 'waste_records';
  static const String certificationsCollection = 'certifications';
  static const String energyTipsCollection = 'energy_tips';
  static const String ecoTravelCollection = 'eco_travel';
  static const String contactMessagesCollection = 'contact_messages';

  // SharedPreferences Keys
  static const String isLoggedInKey = 'isLoggedIn';
  static const String userIdKey = 'userId';
  static const String userEmailKey = 'userEmail';
  static const String userNameKey = 'userName';
  static const String isDarkModeKey = 'isDarkMode';
  static const String onboardingCompleteKey = 'onboardingComplete';
  static const String rememberMeKey = 'rememberMe';

  // Carbon Footprint Emission Factors (kg CO2 per unit)
  static const double carEmissionFactor = 0.21; // per km
  static const double busEmissionFactor = 0.089; // per km
  static const double trainEmissionFactor = 0.041; // per km
  static const double flightEmissionFactor = 0.255; // per km
  static const double electricityEmissionFactor = 0.42; // per kWh
  static const double naturalGasEmissionFactor = 2.0; // per m3
  static const double beefEmissionFactor = 27.0; // per kg
  static const double poultryEmissionFactor = 6.9; // per kg
  static const double vegetablesEmissionFactor = 2.0; // per kg
  static const double waterEmissionFactor = 0.00034; // per liter

  // Sustainability Score Thresholds
  static const int scoreExcellent = 90;
  static const int scoreGood = 70;
  static const int scoreAverage = 50;
  static const int scorePoor = 30;

  // Pagination
  static const int defaultPageSize = 20;

  // Admin Role
  static const String adminRole = 'admin';
  static const String userRole = 'user';
}
