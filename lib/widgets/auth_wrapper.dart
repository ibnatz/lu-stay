import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../pages/login.dart';
import '../pages/homepage.dart';
import '../pages/email_verification_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService authService = AuthService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await authService.initializeAuthState();
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final User? user = snapshot.data;

        // If user is signed in but email is not verified
        if (user != null && !user.emailVerified) {
          return EmailVerificationPage(email: user.email!);
        }

        // If user is signed in and email is verified (either Firebase or SharedPreferences)
        if ((user != null && user.emailVerified) || authService.isLoggedIn) {
          return const Homepage();
        }

        // If user is not signed in, show login page
        return const LoginPage();
      },
    );
  }
}