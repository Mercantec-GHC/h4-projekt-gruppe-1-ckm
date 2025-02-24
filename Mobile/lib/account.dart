import 'dart:convert';
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:Mobile/auth_service.dart';
import 'package:Mobile/login.dart';
import 'package:http/http.dart' as http;

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  bool isPasswordVisible = false; // To toggle password visibility
  bool isChanged = false;
  String? successMessage;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
   String? token = await AuthService().getToken(); // Retrieve token

    if (token != null) {
      print("JWT Token: $token"); // Print full token for debugging

      if (!JwtDecoder.isExpired(token)) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print("Decoded Token: $decodedToken"); // Print decoded token

        setState(() {
          emailController.text = decodedToken['email'] ?? 'No email in token';
          usernameController.text =
              decodedToken['name'] ?? 'No username in token'; 
        });
      } else {
        print("Token is expired");
      }
    } else {
      print("No token found");
    }
  }

void logout() async {
  await AuthService().deleteToken();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Login()), // Redirect to login
  );
}

void saveChanges() async {
  print("saveChanges() started...");

  // Step 1: Retrieve the token
  String? token = await AuthService().getToken();
  if (token == null) {
    print("ERROR: Token is null!");
    return;
  }
  print("Token retrieved successfully.");

  // Step 2: Decode the token to get user ID
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  print("Decoded token: $decodedToken");

  String? userId = decodedToken["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];
  if (userId == null) {
    print("ERROR: User ID is null!");
    return;
  }
  print("User ID extracted: $userId");

  // Step 3: Prepare request data
  Map<String, String> updatedData = {
    "email": emailController.text,
    "username": usernameController.text,
    "password": passwordController.text,
  };
  print("Updated data: $updatedData");

  // Step 4: Send the API request
  String apiUrl = "https://localhost:7173/api/Users/$userId";
  print("Sending request to: $apiUrl");

  try {
    var response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updatedData),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 204) {
      logout();
    }
  } catch (e) {
    print("ERROR: Exception occurred: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Account",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple)),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), isDense: true),
                    onChanged: (_) => setState(() => isChanged = true),
                  ),
                  const SizedBox(height: 10),
                  const Text("Username",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple)),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), isDense: true),
                    onChanged: (_) => setState(() => isChanged = true),
                  ),
                  const SizedBox(height: 10),
                  const Text("Password",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple)),
                  const Text(
                    "Enter your current password or a new one.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible, // Hide or show password
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isChanged ? saveChanges : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isChanged ? Colors.purple : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Center(child: Text("Save Changes")),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (successMessage != null)
              Text(successMessage!,
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            if (errorMessage != null)
              Text(errorMessage!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: logout, // Call logout function
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Center(child: Text("Logout")),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
