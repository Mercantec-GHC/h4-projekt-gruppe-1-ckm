import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(BrickBreakerApp());

class BrickBreakerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brick Breaker',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: BrickBreakerGame(),
    );
  }
}

class BrickBreakerGame extends StatefulWidget {
  @override
  _BrickBreakerGameState createState() => _BrickBreakerGameState();
}

class _BrickBreakerGameState extends State<BrickBreakerGame> {
  double _paddlePosition = 0.0;

  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _paddlePosition += event.x * 10; // Use event.x for landscape mode
        if (_paddlePosition < 0) {
          _paddlePosition = 0;
        } else if (_paddlePosition > MediaQuery.of(context).size.width - 100) {
          _paddlePosition = MediaQuery.of(context).size.width - 100;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brick Breaker'),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 20,
            left: _paddlePosition,
            child: Container(
              width: 100,
              height: 20,
              color: Colors.purple,
            ),
          ),
          // Add other game elements here
        ],
      ),
    );
  }
}
