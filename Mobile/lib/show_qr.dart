import 'package:Mobile/auth_service.dart';
import 'package:Mobile/dashboard.dart';
import 'package:Mobile/statistics.dart';
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowQr extends StatefulWidget {
  final String qrId;
  const ShowQr({super.key, required this.qrId});  
  @override
  _ShowQrState createState() => _ShowQrState();
}

class _ShowQrState extends State<ShowQr> {
  String? errorMessage;
  String result = '';
  String titleHint = "Fetching title...";

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
      });
    } else {
      setState(() {
        errorMessage = "Get failed: ${response.body}: ${response.statusCode}";
      });
    }
  }

  Future<void> _deleteQr() async {
    String? token = await AuthService().getToken();
    if (token == null) return;
    try {
      var response = await http.delete(
        Uri.parse('https://localhost:7173/api/QrCodes/{id}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token'
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
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

  Future<void> _comfirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comfirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _deleteQr();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Statistics()),
                    );
                  },
                ),
              ),
              Container(
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _comfirmDelete();
                  },
                ),
              ),
              Container(
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Statistics()),
                    );
                  },
                ),
              ),
            ],
          ),
          Image.asset('assets/qr.png', width: 400),
          Text(
            titleHint,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          SizedBox(
            height: 50,
            width: 180,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6F58C9),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Show content',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                // Navigator.pushNamed(context, '/');
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
