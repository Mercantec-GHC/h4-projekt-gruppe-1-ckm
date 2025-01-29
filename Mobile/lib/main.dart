import 'package:flutter/material.dart';
import 'package:qonnect/login.dart';
import 'package:qonnect/signup.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/signup': (context) => const Signup(),
        '/login': (context) => const Login(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff46006F),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/mikkelfonden.png', height: 26, width: 220),
          const SizedBox(height: 20),
          Image.asset('assets/qonnect.png', height: 50, width: 250),
          const Align(
            alignment: Alignment.center,
          ),
           const SizedBox(height: 70),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6F58C9),
              foregroundColor: Colors.white,
            ),
            child: const Text('login'),
             onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
           const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6F58C9),
              foregroundColor: Colors.white,
            ),
            child: const Text('signup'),
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
    );
  }
}
