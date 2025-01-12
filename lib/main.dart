import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';  // Import the generated file
import 'login.dart';  // Import your login page
import 'home.dart';  // Import your home page
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiva',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const AuthGate(),  // This is the new entry point
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Check if the user is already signed in
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),  // Listen to auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading while checking
        }

        if (snapshot.hasData) {
          return const HomePage();  // Navigate to HomePage if the user is signed in
        } else {
          return const LoginPage();  // Navigate to LoginPage if no user is signed in
        }
      },
    );
  }
}
