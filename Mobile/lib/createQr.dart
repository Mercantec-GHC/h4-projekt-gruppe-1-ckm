import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateQr extends StatefulWidget {
  const CreateQr({super.key});

  @override
  _CreateQrState createState() => _CreateQrState();
}

class _CreateQrState extends State<CreateQr> {
  String _errorMessage = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/qonnect.png', height: 50, width: 250),
          const Align(
            alignment: Alignment.center,
          ),
          // The header text
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
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
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
                        Uri.parse('https://yourapi.com/create'),
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
    );
  }
}
