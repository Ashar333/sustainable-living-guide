import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/carbon_tracker/carbon_tracker_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/challenges/challenges_screen.dart';
import '../../screens/certifications/certifications_screen.dart';
import '../../screens/waste_tracker/waste_tracker_screen.dart';
import '../../screens/recipes/recipes_screen.dart';
import '../../screens/energy_tips/energy_tips_screen.dart';
import '../../screens/eco_travel/eco_travel_screen.dart';
import '../../screens/forum/forum_screen.dart';
import '../../screens/progress_dashboard/progress_dashboard_screen.dart';
import '../../screens/educational/educational_screen.dart';
import '../../screens/contact/contact_screen.dart';
import '../../screens/gallery/gallery_screen.dart';
import '../../screens/admin/admin_screen.dart';
import '../../screens/general/about_screen.dart';
import '../../screens/general/faq_screen.dart';
import '../../screens/general/settings_screen.dart';
import '../../screens/general/profile_screen.dart';

/// Application route management.
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String carbonTracker = '/carbon-tracker';
  static const String products = '/products';
  static const String challenges = '/challenges';
  static const String certifications = '/certifications';
  static const String wasteTracker = '/waste-tracker';
  static const String recipes = '/recipes';
  static const String energyTips = '/energy-tips';
  static const String ecoTravel = '/eco-travel';
  static const String forum = '/forum';
  static const String progressDashboard = '/progress-dashboard';
  static const String educational = '/educational';
  static const String contact = '/contact';
  static const String gallery = '/gallery';
  static const String admin = '/admin';
  static const String about = '/about';
  static const String faq = '/faq';
  static const String settings = '/settings';
  static const String profile = '/profile';

  /// Generate routes for Navigator.
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case carbonTracker:
        return MaterialPageRoute(builder: (_) => const CarbonTrackerScreen());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case challenges:
        return MaterialPageRoute(builder: (_) => const ChallengesScreen());
      case certifications:
        return MaterialPageRoute(builder: (_) => const CertificationsScreen());
      case wasteTracker:
        return MaterialPageRoute(builder: (_) => const WasteTrackerScreen());
      case recipes:
        return MaterialPageRoute(builder: (_) => const RecipesScreen());
      case energyTips:
        return MaterialPageRoute(builder: (_) => const EnergyTipsScreen());
      case ecoTravel:
        return MaterialPageRoute(builder: (_) => const EcoTravelScreen());
      case forum:
        return MaterialPageRoute(builder: (_) => const ForumScreen());
      case progressDashboard:
        return MaterialPageRoute(
            builder: (_) => const ProgressDashboardScreen());
      case educational:
        return MaterialPageRoute(builder: (_) => const EducationalScreen());
      case contact:
        return MaterialPageRoute(builder: (_) => const ContactScreen());
      case gallery:
        return MaterialPageRoute(builder: (_) => const GalleryScreen());
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case faq:
        return MaterialPageRoute(builder: (_) => const FaqScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
