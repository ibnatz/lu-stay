import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfigService {
  static bool _isInitialized = false;

  static String get apiKey => _getEnv('FIREBASE_API_KEY');
  static String get androidAppId => _getEnv('FIREBASE_ANDROID_APP_ID');
  static String get iosAppId => _getEnv('FIREBASE_IOS_APP_ID');
  static String get messagingSenderId => _getEnv('FIREBASE_MESSAGING_SENDER_ID');
  static String get projectId => _getEnv('FIREBASE_PROJECT_ID');
  static String get authDomain => _getEnv('FIREBASE_AUTH_DOMAIN');
  static String get storageBucket => _getEnv('FIREBASE_STORAGE_BUCKET');

  static String _getEnv(String key) {
    if (!_isInitialized) {
      throw Exception('FirebaseConfigService not initialized. Call initialize() first.');
    }

    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw Exception('Environment variable $key is not set or empty');
    }
    return value;
  }

  // Initialize environment variables
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      print('Environment variables loaded successfully');
    } catch (e) {
      throw Exception('Failed to load environment variables: $e');
    }
  }
}