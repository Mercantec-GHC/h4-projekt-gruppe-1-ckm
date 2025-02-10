import 'package:flutter/material.dart';
import 'package:Mobile/createQr.dart'; // Import the CreateQr widget

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Widget> buttons = [];

  @override
  void initState() {
    super.initState();
    buttons.add(createButton());
  }

  Widget createButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 184, 184, 184),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: EdgeInsets.zero, // Remove default padding
      ),
      child: const Icon(
        Icons.add,
        size: 60, // Change the size of the icon
        color: Color.fromARGB(255, 0, 0, 0), // Change the color of the icon
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateQr()),
        );
      },
    );
  }

  void addQrButton() {
    setState(() {
      buttons.add(createButton());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/qonnect.png', height: 50, width: 250),
          const Align(
            alignment: Alignment.center,
          ),
          if (buttons.length >= 12)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search QR Codes',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          if (buttons.length >= 12)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateQr()),
                    );
                  },
                  child: const Text('Add QR Code'),
                ),
              ],
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 1, // Make the buttons square
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return buttons[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
