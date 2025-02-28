import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';

class Statistics extends StatefulWidget {
  final String qrCodeId;
  const Statistics({super.key, required this.qrCodeId});

  @override
  _ShowQrState createState() => _ShowQrState();
}

class _ShowQrState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: null,
      bottomNavigationBar: Footer(),
    );
  }
}
