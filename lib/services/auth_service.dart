import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Map<String, dynamic>? _currentUserData;
  static bool _isLoggedIn = false;

  Map<String, dynamic>? get currentUser => _currentUserData;
  bool get isLoggedIn => _isLoggedIn;

  // Added this getter for authStateChanges
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email validation regex
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Password validation
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Client-side validation
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        return 'All fields are required';
      }

      if (!_isValidEmail(email)) {
        return 'Wrong email format';
      }

      if (!_isValidPassword(password)) {
        return 'Password must be at least 6 characters';
      }

      if (fullName.trim().length < 2) {
        return 'Name must be at least 2 characters';
      }

      // Created user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Updated user profile with full name
      await result.user?.updateDisplayName(fullName);

      // Send email verification
      await result.user?.sendEmailVerification();

      // Saved to Firestore
      try {
        await _firestore.collection('users').doc(result.user?.uid).set({
          'uid': result.user?.uid,
          'email': email,
          'fullName': fullName,
          'emailVerified': false,
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
      await prefs.setBool('emailVerified', false);

      _isLoggedIn = true;
      _currentUserData = {
        'email': email,
        'fullName': fullName,
        'uid': result.user?.uid,
        'emailVerified': false
      };

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This email is already registered';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        return 'Wrong email format';
      }
      return e.message ?? 'An error occurred during sign up';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Client-side validation
      if (email.isEmpty || password.isEmpty) {
        return 'Email and password are required';
      }

      if (!_isValidEmail(email)) {
        return 'Wrong email format';
      }

      // Sign in with Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!result.user!.emailVerified) {
        // Send new verification email
        await result.user!.sendEmailVerification();
        await _auth.signOut();
        return 'email_not_verified';
      }

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
      await prefs.setBool('emailVerified', true);

      _isLoggedIn = true;
      _currentUserData = {
        'email': email,
        'fullName': userData['fullName'] ?? result.user?.displayName,
        'uid': result.user?.uid,
        'emailVerified': true
      };

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        return 'Wrong email format';
      } else if (e.code == 'user-disabled') {
        return 'This account has been disabled';
      }
      return e.message ?? 'An error occurred during sign in';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  // ... rest of your AuthService methods remain the same
  // Send email verification
  Future<void> sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Password reset error: $e");
      rethrow;
    }
  }

// Generate random verification code
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // 6-digit code
  }

// Store verification code in Firestore
  Future<void> _storeVerificationCode(String email, String code) async {
    try {
      await _firestore.collection('verification_codes').doc(email).set({
        'code': code,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error storing verification code: $e");
      rethrow;
    }
  }

// Verify the code entered by user
  Future<bool> verifyEmailCode(String email, String enteredCode) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('verification_codes').doc(email).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String storedCode = data['code'];
        Timestamp createdAt = data['createdAt'];

        // Check if code is expired (10 minutes)
        DateTime now = DateTime.now();
        DateTime createdTime = createdAt.toDate();
        Duration difference = now.difference(createdTime);

        if (difference.inMinutes > 10) {
          // Code expired
          await _firestore.collection('verification_codes').doc(email).delete();
          return false;
        }

        if (storedCode == enteredCode) {
          // Code is valid - mark email as verified in Firestore
          User? user = _auth.currentUser;
          if (user != null) {
            // Update user document
            await _firestore.collection('users').doc(user.uid).update({
              'emailVerified': true,
            });

            // Update SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('emailVerified', true);

            // Delete used code
            await _firestore.collection('verification_codes').doc(email).delete();

            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print("Error verifying code: $e");
      return false;
    }
  }

// Send verification email with code (replace the old sendVerificationEmail)
  Future<void> sendVerificationEmailWithCode(String email) async {
    try {
      String verificationCode = _generateVerificationCode();

      // Store code in Firestore
      await _storeVerificationCode(email, verificationCode);

      // Here you would integrate with your email service
      // For now, we'll just print it and you can set up email sending later
      print('Verification code for $email: $verificationCode');

      // TODO: Integrate with your email service (SendGrid, SMTP, etc.)
      // await _sendActualEmail(email, verificationCode);

    } catch (e) {
      print("Error sending verification email: $e");
      rethrow;
    }
  }

  // check if email is actually verified
  Future<bool> checkEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Reload user to get latest email verification status from Firebase
        await user.reload();
        user = _auth.currentUser; // Get updated user data
        return user?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      print("Error checking email verification: $e");
      return false;
    }
  }

  // Check if current user is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;

    // Fallback to SharedPreferences if Firestore fails
    return {
      'fullName': prefs.getString('fullName') ?? 'User',
      'email': prefs.getString('email') ?? '',
      'uid': prefs.getString('uid') ?? user?.uid,
      'emailVerified': prefs.getBool('emailVerified') ?? false,
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
        'emailVerified': prefs.getBool('emailVerified') ?? false,
      };
    }
  }
}