import 'package:Mobile/templates/footer.dart';
import 'package:Mobile/templates/header.dart';
import 'package:flutter/material.dart';

class Camera extends StatelessWidget {
  const Camera({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Center(
        child: Text(
          "Camera Screen",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
