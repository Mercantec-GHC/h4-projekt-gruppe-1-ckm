import 'package:flutter/material.dart';
import 'package:Mobile/createQr.dart'; // Import the CreateQr widget

// Dashboard Widget
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

// Dashboard State
class DashboardState extends State<Dashboard> {
  List<Widget> buttons = [];

  @override
  void initState() {
    super.initState();
    buttons.add(createButton());
  }

  // Method to create a button
  Widget createButton() {
    return Column(
      children: [
        SizedBox(
          width: 100, // Set a fixed width
          height: 100, // Set a fixed height
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 184, 184, 184),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 60, // Change the size of the icon
              color:
                  Color.fromARGB(255, 0, 0, 0), // Change the color of the icon
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateQr()),
              );
            },
          ),
        ),
        const SizedBox(
            height: 8), // Add some space between the button and the title
        buildTitle(),
      ],
    );
  }

  String placeholderTitle = "Title";
  String? qrTitle;

  // Method to build the title
  Widget buildTitle() {
    return Text(
      qrTitle ?? placeholderTitle,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xff6F58C9),
      ),
    );
  }

  // Method to set the QR title
  void setQrTitle(String title) {
    setState(() {
      qrTitle = title;
    });
  }

  // Method to add a new QR button
  void addQrButton() {
    setState(() {
      buttons.add(createButton());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/qonnect.png', height: 50, width: 250),
            const Align(alignment: Alignment.center),
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
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 1, // Make the buttons square
              ),
              itemCount: buttons.length > 12
                  ? 12
                  : buttons.length, // Limit the number of buttons displayed
              itemBuilder: (context, index) {
                return buttons[index];
              },
            ),
          ],
        ),
      ),
    );
  }
}
