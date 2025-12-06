import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/sign_up_login_screen.dart';
import 'screens/auth/select_role_screen.dart';
import 'screens/client/dashboard/today_view_screen.dart';
import 'screens/coach/client_management/client_list_view_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue anyway - the error will be caught when trying to use Firebase
  }
  
  runApp(const CoachDashboardApp());
}

class CoachDashboardApp extends StatelessWidget {
  const CoachDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Coach Dashboard',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that handles authentication routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show loading indicator while checking auth state
    if (authProvider.isLoading && authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If not authenticated, show welcome screen
    if (!authProvider.isAuthenticated) {
      return const WelcomeScreen();
    }

    // If authenticated, check if user has selected a role
    // For now, we'll navigate to role selection after signup/login
    // In a real app, you'd check the user's role from Firestore
    // TODO: Check user role from Firestore and route accordingly
    // For now, we'll show role selection screen
    // This should be replaced with actual role checking logic
    
    // Temporary: Always show role selection after login
    // In production, you'd check the user's role from UserProvider
    return const SelectRoleScreen();
  }
}
