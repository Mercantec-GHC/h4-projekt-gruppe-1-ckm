import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:Mobile/dashboard.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

// Main widget for creating QR code

class CreateQr extends StatefulWidget {
  const CreateQr({super.key});

  @override
  CreateQrState createState() => CreateQrState();
}

class CreateQrState extends State<CreateQr> {
  String result = ''; // To store the result from the API call
  String apiUrl = 'https://localhost:7173/api/QrCodes';
  final AuthService _authService = AuthService(); // Added AuthService
  final TextEditingController titleController = TextEditingController();
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    super.dispose();
  }

  Future<void> _postQrCode() async {
    try {
      // Retrieve the token from the AuthService
      String? token = await AuthService().getToken();

      if (token == null) {
        setState(() {
          result = 'Error: Token not found. Please log in again.';
        });
        return;
      }

      Map<String, dynamic> body = {
        'title': titleController.text.trim(),
        'text': textController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include the token in the headers
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

     if (response.statusCode == 200 || response.statusCode == 201) {
        
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
      } else {
        setState(() {
          result = 'create Failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  // This is the body of the CreateQr widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                      "Create Qr Code",
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: "Title",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.purple.withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.title),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: "Link/Text",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.purple.withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.link),
                          ),
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
                            onPressed: _postQrCode,
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xff6F58C9),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Create",
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
        bottomNavigationBar: const Footer(),
      ),
    );
  }
}
