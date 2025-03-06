import 'package:Mobile/auth_service.dart';
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Statistics extends StatefulWidget {
  final String qrCodeId;
  final String qrCodeTitle;
  const Statistics(
      {super.key, required this.qrCodeId, required this.qrCodeTitle});

  @override
  _ShowQrState createState() => _ShowQrState();
}

class _ShowQrState extends State<Statistics> {
  String? errorMessage;
  String apiUrl = 'https://localhost:7173/api/';
  int? scanning;

  @override
  void initState() {
    super.initState();
    _loadQrcodeStatistics();
  }

  Future<void> _loadQrcodeStatistics() async {
    String? token = await AuthService().getToken();
    if (token == null) return;

    try {
      var statisticsResponse = await http.get(
        Uri.parse('${apiUrl}Qrcodes/scan/${widget.qrCodeId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token'
        },
      );
    if (statisticsResponse.statusCode == 200) {
        var jsonData = jsonDecode(statisticsResponse.body);
        setState(() {
          scanning = jsonData['scannings'];
          print(scanning);
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch data: ${statisticsResponse.statusCode}";
          print("$scanning hej");
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "error $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Text("${widget.qrCodeTitle} er blevet scannet $scanning."),
      bottomNavigationBar: Footer(),
    );
  }
}
