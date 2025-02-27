import 'package:Mobile/show_qr.dart';
import 'package:flutter/material.dart';
import 'package:Mobile/createQr.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'auth_service.dart';
import 'dart:convert';
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  String? errorMessage;
  List<Map<String, String>> userQrCodes = [];
  List<Map<String, String>> searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchUserQrCodes();
  }

  Future<void> _fetchUserQrCodes() async {
    String? token = await AuthService().getToken();
    if (token == null) return;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userId = decodedToken[
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"]
        .toString();

    try {
      var userQrResponse = await http.get(
        Uri.parse('https://localhost:7173/api/User_QrCode'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token'
        },
      );

      if (userQrResponse.statusCode == 200) {
        List<dynamic> userQrData = jsonDecode(userQrResponse.body);

        // Filter QR codes for logged-in user, ensuring both values are strings
        List<int> userQrIds = userQrData
            .where((qr) =>
                qr["user_id"].toString() == userId) // Compare both as strings
            .map<int>((qr) => qr["qr_id"])
            .toList();

        // Fetch full QR details from /api/QrCodes
        var allQrResponse = await http.get(
          Uri.parse('https://localhost:7173/api/QrCodes'),
          headers: {"Content-Type": "application/json"},
        );

        if (allQrResponse.statusCode == 200) {
          List<dynamic> allQrData = jsonDecode(allQrResponse.body);

          // Match and collect user QR codes, including qr_id
          setState(() {
            userQrCodes = allQrData
                .where((qr) => userQrIds.contains(qr["id"]))
                .map((qr) => {
                      "qr_id": qr["id"].toString(), // Add qr_id here
                      "text": qr["text"].toString(),
                      "title": qr["title"]?.toString() ??
                          "Untitled QR" // Ensure title is a string
                    })
                .toList();
          });
        } else {
          setState(() {
            errorMessage = "Failed to fetch QR code details.";
          });
        }
      } else {
        setState(() {
          errorMessage = "Error fetching user QR codes: ${userQrResponse.body}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  final query = controller.text.toLowerCase();
                  if (query.isEmpty) {
                    return [];
                  }
                  final suggestions = userQrCodes
                      .where((qr) =>
                          qr["title"]?.toLowerCase().contains(query) ?? false)
                      .toList();

                  return List<Widget>.generate(suggestions.length, (int index) {
                    final String item =
                        suggestions[index]["title"] ?? "Untitled QR";
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        controller.closeView(item);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowQr(
                              qrCodeId: suggestions[index]["qr_id"]!,
                            ),
                          ),
                        );
                      },
                    );
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: userQrCodes.length + 1,
                  itemBuilder: (context, index) {
                    if (index < userQrCodes.length) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to ShowQr screen with the QR ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowQr(
                                qrCodeId: userQrCodes[index]["qr_id"]!,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 110,
                              width: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: QrImageView(
                                data: userQrCodes[index]["text"] ?? "",
                                version: QrVersions.auto,
                                size: 140,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userQrCodes[index]["title"] ?? "Untitled QR",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the CreateQrPage when "Add QR-code" is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateQr(), // Navigate to CreateQrPage
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 110,
                              width: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.add,
                                    size: 50, color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Add QR-code",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
