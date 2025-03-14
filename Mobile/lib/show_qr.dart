import 'package:Mobile/auth_service.dart';
import 'package:Mobile/dashboard.dart';
import 'package:Mobile/editQr.dart';
import 'package:Mobile/statistics.dart';
import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQr extends StatefulWidget {
  final String qrCodeId;

  const ShowQr({super.key, required this.qrCodeId});

  @override
  _ShowQrState createState() => _ShowQrState();
}

class _ShowQrState extends State<ShowQr> {
  // Error message to display in case of an error
  String? errorMessage;
  String result = '';
  String titleHint = "Fetching title...";
  String textHint = "Fetching text...";

  @override
  void initState() {
    super.initState();
    _getQr();
    _incrementScanning();
  }

  Future<void> _getQr() async {
    String? token = await AuthService().getToken();
    if (token == null) return;

    var response = await http.get(
        Uri.parse('https://localhost:7173/api/QrCodes/${widget.qrCodeId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token'
        });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        textHint = data['text'] ?? '';
        titleHint = data['title'] ?? '';
      });
    } else {
      setState(() {
        errorMessage = "QR failed to load.";
      });
    }
  }

  Future<void> _incrementScanning() async {
    String? token = await AuthService().getToken();
    if (token == null) return;

    var response = await http.put(
        Uri.parse(
            'https://localhost:7173/api/QrCodes/Scanning/${widget.qrCodeId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token'
        });
    if (response.statusCode == 200) {
      setState(() {
        print('Ok');
      });
    } else {
      setState(() {
        errorMessage = "Imcrement failed.";
        print(errorMessage);
      });
    }
  }

  // Preview of content
  void _showContentDialog(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("QR Code Content"),
          content: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> incrementScanCount() async {
    final url =
        Uri.parse('https://localhost:7173/api/QrCode/${widget.qrCodeId}');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully incremented scan count
      final responseData = json.decode(response.body);
      print(
          "QR Code ID: ${responseData['Id']}, Scan Count: ${responseData['Scannings']}");
    } else {
      // Handle error
      print("Failed to update scan count");
    }
  }

  Future<void> _deleteQr() async {
    String? token = await AuthService().getToken();
    if (token == null) return;
    try {
      var response = await http.delete(
        Uri.parse('https://localhost:7173/api/QrCodes/${widget.qrCodeId}'),
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
        errorMessage = "Delete failed";
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  // Confirm deletion via dialog
  Future<void> _comfirmDelete() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comfirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this QR code?'),
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
              // Information btn
              Container(
                child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Statistics(
                          qrCodeId: widget.qrCodeId,
                          qrCodeTitle: titleHint,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Delete btn
              Container(
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 40,
                  onPressed: () {
                    _comfirmDelete();
                  },
                ),
              ),
              // Edit btn
              Container(
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditQr(
                                qrCodeId: widget.qrCodeId,
                              )),
                    );
                  },
                ),
              ),
            ],
          ),
          // Show QR
          Column(
            children: [
              // Generated QR code
              textHint.isNotEmpty
                  ? QrImageView(
                      data: textHint,
                      version: QrVersions.auto,
                      size: 300.0,
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Error: QR Code data is empty.",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              Text(
                titleHint,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(
                height: 50,
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 28, 28, 31),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Show content',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    _showContentDialog(textHint);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
