import 'package:flutter/material.dart';

class CreateQr extends StatefulWidget {
  const CreateQr({super.key});

  @override
  _CreateQrState createState() => _CreateQrState();
}

class _CreateQrState extends State<CreateQr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage('assets/qonnect.png'),
            width: 275,
          ),
          SizedBox(height: 20.0),
          Text(
            "Login",
            style: TextStyle(
              color: Color(0xff6F58C9),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Align(
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}
