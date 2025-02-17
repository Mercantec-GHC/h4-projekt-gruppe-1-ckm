import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/auth_service.dart';

// Main widget for creating QR code
class CreateQr extends StatefulWidget {
  const CreateQr({super.key});

  @override
  _CreateQrState createState() => _CreateQrState();
}

class _CreateQrState extends State<CreateQr> {
  String _errorMessage = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  Future<QrCode>? _futureQrCode;

  // Function to create QR code by making a POST request
  Future<QrCode> createQrCode(String title, String link) async {
    final response = await http.post(
      Uri.parse('https://localhost:7173/api/QrCodes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'link': link,
      }),
    );

    if (response.statusCode == 200) {
      return QrCode.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create QR code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: const Footer(),
    );
  }

  // Build the app bar with a back button
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  // Build the main body of the screen
  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset('assets/qonnect.png', height: 50, width: 250),
        const Align(alignment: Alignment.center),
        _buildTitle(),
        const Align(alignment: Alignment.center),
        _buildForm(),
      ],
    );
  }

  // Build the title section
  Padding _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Create",
        style: TextStyle(
          color: Color(0xff6F58C9),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build the form with text fields and button
  Padding _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildTextField(_titleController, "Title", Icons.title),
          const SizedBox(height: 20),
          _buildTextField(_linkController, "Link/Text", Icons.link),
          const SizedBox(height: 20),
          _buildCreateButton(),
          if (_errorMessage.isNotEmpty) _buildErrorMessage(),
          if (_futureQrCode != null) buildFutureBuilder(),
        ],
      ),
    );
  }

  // Build a text field with given controller, hint text, and icon
  TextField _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.purple.withOpacity(0.1),
        filled: true,
        prefixIcon: Icon(icon),
      ),
    );
  }

  // Build the create button
  SizedBox _buildCreateButton() {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _errorMessage = '';
            _futureQrCode = createQrCode(
              _titleController.text,
              _linkController.text,
            );
          });
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
    );
  }

  // Build the error message widget
  Padding _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  // Build the future builder to handle the QR code creation result
  FutureBuilder<QrCode> buildFutureBuilder() {
    return FutureBuilder<QrCode>(
      future: _futureQrCode,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text('QR Code created: ${snapshot.data!.title}');
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

// Model class for QR code
class QrCode {
  final String title;
  final String link;

  QrCode({required this.title, required this.link});

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      title: json['title'] as String,
      link: json['link'] as String,
    );
  }
}
