/// This file contains the implementation of a Flutter widget that allows users to create a QR code by providing a title and a link/text.

/// Import necessary packages
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// CreateQr widget
class CreateQr extends StatefulWidget {
  const CreateQr({super.key});

  @override
  _CreateQrState createState() => _CreateQrState();
}

/// State class for CreateQr widget
class _CreateQrState extends State<CreateQr> {
  /// Error message to display in case of an error
  String _errorMessage = '';

  /// Controllers for the text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App bar with a back button
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Fix later const Header(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// Logo image
          Image.asset('assets/qonnect.png', height: 50, width: 250),
          const Align(
            alignment: Alignment.center,
          ),

          /// Header text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Create",
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
                /// Title input field
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      hintText: "Title",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.title)),
                ),
                const SizedBox(height: 20),

                /// Link/Text input field
                TextField(
                  controller: _linkController,
                  decoration: InputDecoration(
                    hintText: "Link/Text",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.link),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                /// Create button
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Clear the error message
                      setState(() {
                        _errorMessage = '';
                      });

                      // Validate input fields
                      if (_titleController.text.isEmpty ||
                          _linkController.text.isEmpty) {
                        setState(() {
                          _errorMessage = 'Please fill in all fields';
                        });
                        return;
                      }

                      // Make the API call
                      final response = await http.post(
                        Uri.parse('https://localhost:7173/api/QrCodes'),
                        body: {
                          'title': _titleController.text,
                          'link': _linkController.text,
                        },
                      );

                      if (response.statusCode == 200) {
                        // Navigate to the dashboard page
                        Navigator.of(context)
                            .pushReplacementNamed('/dashboard');
                      } else {
                        // Handle the error
                        setState(() {
                          _errorMessage = 'Failed to create QR code';
                        });
                      }
                    },
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

                /// Error message display
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
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
