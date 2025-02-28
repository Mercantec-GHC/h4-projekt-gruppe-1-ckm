import 'package:Mobile/templates/footerOnlyHome.dart';
import 'package:flutter/material.dart';
import 'package:Mobile/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:Mobile/auth_service.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService(); // Added AuthService
  String apiUrl = 'https://localhost:7173/api/Users/login';
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String result = ''; // To store the result from the API call

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _postUser() async {
    try {
      Map<String, dynamic> body = {
        'username': usernameController.text.trim(),
        'password': passwordController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String? token = responseData['token'];

        if (token != null) {
          await _authService.saveToken(token); // Save token securely
          setState(() {
            result = 'Login Successful!';
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } 
      } else {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);

        if (errorData.containsKey('message')) {
          // Handle login errors (format: { "message": "Invalid username or password" })
          setState(() {
            result = 'Login Failed: ${errorData['message']}';
          });
        } else {
          // Handle unexpected error format
          setState(() {
            result = 'Login Failed: ${response.body}';
          });
        }
      } catch (e) {
        // Handle JSON parsing errors
        setState(() {
          result = 'Login Failed: ${response.body}';
        });
      }
    }
  } catch (e) {
    setState(() {
      result = 'Error: $e';
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Column(
                  children: <Widget>[
                    SizedBox(height: 60.0),
                    Image(
                      image: AssetImage('assets/qonnect.png'),
                      height: 70,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xff6F58C9),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 320, // 10 wider than the text fields and buttons
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                              hintText: "Username",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none),
                              fillColor: Colors.purple.withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(Icons.person)),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: Colors.purple.withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.password),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          result,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _postUser,
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xff6F58C9),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Don't have a user?\n"
                          "Click sign up to create a user",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xff6F58C9),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const FooterOnlyHome(),
      );
  }
}
