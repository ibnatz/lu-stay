import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/favorite_service.dart';
import 'services/auth_service.dart';
import 'widgets/auth_wrapper.dart';
import 'services/firebase_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("Loading environment variables...");
    await FirebaseConfigService.initialize();
    print("Environment variables loaded successfully");

    print("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => FavoriteService()),
      ],
      child: MaterialApp(
        title: 'Accommodation App',
        theme: ThemeData(
          primaryColor: const Color(0xFFFF6B6B),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}