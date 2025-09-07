import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Map<String, dynamic>? _currentUserData;
  static bool _isLoggedIn = false;

  Map<String, dynamic>? get currentUser => _currentUserData;
  bool get isLoggedIn => _isLoggedIn;

  // Added this getter for authStateChanges
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        return 'All fields are required';
      }

      if (password.length < 6) {
        return 'Password must be at least 6 characters';
      }

      // Created user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Updated user profile with full name
      await result.user?.updateDisplayName(fullName);

      // Saved to Firestore
      try {
        await _firestore.collection('users').doc(result.user?.uid).set({
          'uid': result.user?.uid,
          'email': email,
          'fullName': fullName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Firestore error: $e");
        // Continue without Firestore
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
      await prefs.setString('fullName', fullName);
      await prefs.setString('uid', result.user?.uid ?? '');

      _isLoggedIn = true;
      _currentUserData = {
        'email': email,
        'fullName': fullName,
        'uid': result.user?.uid
      };

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Email and password are required';
      }

      // Sign in with Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Try to get user data from Firestore
      Map<String, dynamic> userData = {};
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(result.user?.uid)
            .get();

        if (userDoc.exists) {
          userData = userDoc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        print("Firestore error: $e");
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
      await prefs.setString('fullName', userData['fullName'] ?? result.user?.displayName ?? '');
      await prefs.setString('uid', result.user?.uid ?? '');

      _isLoggedIn = true;
      _currentUserData = {
        'email': email,
        'fullName': userData['fullName'] ?? result.user?.displayName,
        'uid': result.user?.uid
      };

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;

    // Fallback to SharedPreferences if Firestore fails
    return {
      'fullName': prefs.getString('fullName') ?? 'User',
      'email': prefs.getString('email') ?? '',
      'uid': prefs.getString('uid') ?? user?.uid
    };
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _currentUserData = null;
  }

  // Initialize auth state from SharedPreferences
  Future<void> initializeAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _currentUserData = {
        'email': prefs.getString('email'),
        'fullName': prefs.getString('fullName'),
        'uid': prefs.getString('uid'),
      };
    }
  }
}