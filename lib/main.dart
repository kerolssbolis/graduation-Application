import 'package:flutter/material.dart';
import 'package:traffic_app/roleselectio_screen.dart';
import 'addadmin_screen.dart';
import 'adminadd_user.dart';
import 'adminoption_screen.dart';
import 'splash_screen.dart';
import 'onboarding.dart';
import 'welcome.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Navigation Flow',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreens(),
        '/role_selection': (context) => RoleSelectionScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
        '/admin_options': (context) => const AdminOptionsScreen(),
        '/add_admin': (context) => const AddAdminScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
