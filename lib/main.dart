import 'package:chattrix/firebase_options.dart';
import 'package:chattrix/screens/auth/login_screen.dart';
import 'package:chattrix/screens/auth/signup_screen.dart';
import 'package:chattrix/screens/splash_screen.dart';
import 'package:chattrix/screens/users_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (_) => const SplashScreen(),
    '/login': (_) => LoginScreen(),
    '/signup': (_) => SignupScreen(),
    '/users': (_) => const UsersListScreen(),
  },
);

  }
}
