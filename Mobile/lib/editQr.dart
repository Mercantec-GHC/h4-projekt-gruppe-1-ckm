import 'dart:convert';
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class EditQr extends StatefulWidget {
  const EditQr({super.key});

  @override
  _EditQrState createState() => _EditQrState();
}

class _EditQrState extends State<EditQr> {
  // Controllers for the text fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  // Error message to display in case of an error
  String? errorMessage;
  String? successMessage;
  String result = '';
  String titleHint = "Fetching title...";
  String linkHint = "Fetching link/text...";
  @override
  void dispose() {
    titleController.dispose();
    linkController.dispose();
    super.dispose();
  }

  Future<void> _putQr() async {
    String? token = await AuthService().getToken();
    if (token == null) return;
    try {
      Map<String, dynamic> updatedQr = {
        'title': titleController.text.trim(),
        'text': linkController.text.trim(),
      };
      var response = await http.put(
          Uri.parse('https://localhost:7173/api/QrCodes/{id}'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token'
          },
          body: jsonEncode(updatedQr));
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          successMessage = "Updated successfully";
        });
      } else {
        errorMessage =
            "Update failed: ${response.body}: ${response.statusCode}";
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  Future<void> _getQr() async {
    String? token = await AuthService().getToken();
    if (token == null) return;

    var response = await http
        .get(Uri.parse('https://localhost:7173/api/QrCodes/{id}'), headers: {
      "Content-Type": "application/json",
      "Authorization": 'Bearer $token'
    });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      setState(() {
        titleHint = data['title'] ?? 'Enter Title';
        linkHint = data['text'] ?? 'Enter Link/Text';
      });
    } else {
      setState(() {
        errorMessage = "Get failed: ${response.body}: ${response.statusCode}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with a back button
      appBar: const Header(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Header text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Edit QR",
              style: TextStyle(
                color: Color(0xff6F58C9),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Align(
            alignment: Alignment.center,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Title input field
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      hintText: titleHint,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.title)),
                ),
                const SizedBox(height: 20),

                // Link/Text input field
                TextField(
                  controller: linkController,
                  decoration: InputDecoration(
                    hintText: linkHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 20),

                // Create button
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _putQr,
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xff6F58C9),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Update QR",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
