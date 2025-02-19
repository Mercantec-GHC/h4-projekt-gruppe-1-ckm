import 'package:flutter/material.dart';
import 'package:Mobile/createQr.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'dart:convert';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  String? errorMessage;
  // Stores user's QR codes
  List<String> userQrCodes = [];
  // Stores all QR codes
  List<String> allQrCodes = [];

  @override
  void initState() {
    super.initState();
    _fetchQrCodes();
  }

  // Fetch user's QR codes
  Future<void> _fetchUserQrCodes() async {
    String? token = await AuthService().getToken();
    if (token == null) return;

    try {
      var response = await http.get(
        Uri.parse('https://localhost:7173/api/User_QrCode'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> qrDataList = jsonDecode(response.body);

        setState(() {
          userQrCodes =
              qrDataList.map((qr) => qr["qrCode"].toString()).toList();
        });
      } else {
        setState(() {
          errorMessage =
              "Error: ${response.body} (Status: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch user's QR codes: $e";
      });
    }
  }

  // Fetch all available QR codes
  Future<void> _fetchAllQrCodes() async {
    try {
      var response = await http.get(
        Uri.parse('https://localhost:7173/api/QrCodes'),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> qrDataList = jsonDecode(response.body);

        setState(() {
          allQrCodes = qrDataList.map((qr) => qr["qrCode"].toString()).toList();
        });
      } else {
        setState(() {
          errorMessage =
              "Error: ${response.body} (Status: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch all QR codes: $e";
      });
    }
  }

  // Fetch both user's QR codes and all available QR codes
  Future<void> _fetchQrCodes() async {
    await _fetchUserQrCodes();
    await _fetchAllQrCodes();
  }

  @override
  Widget build(BuildContext context) {
    List<String> displayedQrCodes = [...userQrCodes, ...allQrCodes];

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: displayedQrCodes.length + 1,
          itemBuilder: (context, index) {
            if (index < displayedQrCodes.length) {
              return Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.network(displayedQrCodes[index],
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 4),
                  Text("Title", style: TextStyle(fontSize: 14)),
                ],
              );
            } else {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateQr()),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(Icons.add, size: 40, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Add QR-code", style: TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
