import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/sqlite_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/data_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/data_provider.dart';

/// Application entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  bool isFirebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    isFirebaseAvailable = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e. Running in mock/offline mode.');
  }

  // Initialize services
  final authService = AuthService(useMock: !isFirebaseAvailable);
  final firestoreService = FirestoreService(useMock: !isFirebaseAvailable);
  final sqliteService = SQLiteService();

  // Initialize repositories
  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final dataRepository = DataRepository(
    firestore: firestoreService,
    sqlite: sqliteService,
  );

  runApp(
    SustainableLivingApp(
      authRepository: authRepository,
      dataRepository: dataRepository,
    ),
  );
}

/// Root widget of the Sustainable Living Guide app.
class SustainableLivingApp extends StatelessWidget {
  final AuthRepository authRepository;
  final DataRepository dataRepository;

  const SustainableLivingApp({
    super.key,
    required this.authRepository,
    required this.dataRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DataProvider(repository: dataRepository),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Sustainable Living Guide',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
