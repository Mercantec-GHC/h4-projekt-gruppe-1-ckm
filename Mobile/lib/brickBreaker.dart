import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BrickBreaker extends StatelessWidget {
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
  int _score = 0;

  Timer? _timer;
  Timer? _movementTimer;
  Timer? _brickMovementTimer; // Timer for moving bricks down

  bool _isMovingLeft = false;
  bool _isMovingRight = false;

  List<Offset> _brickPositions = [];

  double _paddlePosition = 0.0;
  Offset _ballPosition = Offset(0, 0);
  Offset _ballVelocity = Offset(2, 2); // Ball moves down initially

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBricks();
      setState(() {
        _paddlePosition = (MediaQuery.of(context).size.width - 100) / 2;
        _ballPosition = Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height -
                300); // Ball spawns above the paddle
      });
    });
    gyroscopeEventStream().listen((GyroscopeEvent event) {
      setState(() {
        _paddlePosition += event.x * 2; // Adjust sensitivity as needed
        if (_paddlePosition < 0) {
          _paddlePosition = 0;
        } else if (_paddlePosition > MediaQuery.of(context).size.width - 100) {
          _paddlePosition = MediaQuery.of(context).size.width - 100;
        }
      });
    });

    _startGameLoop();
    _startBrickMovement(); // Start moving bricks down
  }

  void _initializeBricks() {
    double brickWidth = 50.0;
    double brickHeight = 20.0;
    double padding = 5.0;
    double totalBrickWidth = 6 * (brickWidth + padding) - padding;
    double startX = (MediaQuery.of(context).size.width - totalBrickWidth) / 2;
    double startY = 100.0; // Move bricks down

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 6; j++) {
        _brickPositions.add(Offset(startX + j * (brickWidth + padding),
            startY + i * (brickHeight + padding)));
      }
    }
  }

  void _startGameLoop() {
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        _ballPosition += _ballVelocity;

        // Check for collision with walls
        if (_ballPosition.dx <= 10 || // Left wall collision
            _ballPosition.dx >= MediaQuery.of(context).size.width - 30) {
          // Right wall collision
          _ballVelocity = Offset(-1 * _ballVelocity.dx,
              _ballVelocity.dy); // Reverse horizontal direction
        }
        if (_ballPosition.dy <= 10) {
          // Top wall collision
          _ballVelocity = Offset(_ballVelocity.dx,
              -1 * _ballVelocity.dy); // Reverse vertical direction
        } else if (_ballPosition.dy >=
            MediaQuery.of(context).size.height - 50) {
          // Bottom wall collision (game over)
          _timer?.cancel();
          _brickMovementTimer?.cancel(); // Stop brick movement
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Game Over'),
              content: Text('You lost! Your score: $_score'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }

        // Check for collision with paddle
        if (_ballPosition.dy >= MediaQuery.of(context).size.height - 110 &&
            _ballPosition.dy <= MediaQuery.of(context).size.height - 100 &&
            _ballPosition.dx >= _paddlePosition &&
            _ballPosition.dx <= _paddlePosition + 100) {
          _ballVelocity = Offset(_ballVelocity.dx, -1 * _ballVelocity.dy);
        }

        // Check for collision with bricks
        for (int i = 0; i < _brickPositions.length; i++) {
          if (_ballPosition.dx >= _brickPositions[i].dx &&
              _ballPosition.dx <= _brickPositions[i].dx + 50 &&
              _ballPosition.dy >= _brickPositions[i].dy &&
              _ballPosition.dy <= _brickPositions[i].dy + 20) {
            _brickPositions.removeAt(i);
            _ballVelocity = Offset(_ballVelocity.dx, -1 * _ballVelocity.dy);
            _score += 10;
            break;
          }
        }

        // End game if bricks get close to the paddle
        if (_brickPositions.any(
            (brick) => brick.dy >= MediaQuery.of(context).size.height - 100)) {
          _timer?.cancel();
          _brickMovementTimer?.cancel(); // Stop brick movement
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Game Over'),
              content: Text('Your score: $_score'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );

          if (_brickPositions.isEmpty) {
            _timer?.cancel();
            _brickMovementTimer?.cancel(); // Stop brick movement
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Victory'),
                content: Text('Your score: $_score'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      });
    });
  }

  void _startBrickMovement() {
    _brickMovementTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        for (int i = 0; i < _brickPositions.length; i++) {
          _brickPositions[i] =
              Offset(_brickPositions[i].dx, _brickPositions[i].dy + 5);
        }
      });
    });
  }

  void _startMovementTimer() {
    _movementTimer?.cancel(); // Cancel any existing timer
    _movementTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        if (_isMovingLeft) {
          _paddlePosition -= 5;
          if (_paddlePosition < 0) {
            _paddlePosition = 0;
          }
        } else if (_isMovingRight) {
          _paddlePosition += 5;
          if (_paddlePosition > MediaQuery.of(context).size.width - 100) {
            _paddlePosition = MediaQuery.of(context).size.width - 100;
          }
        }
      });
    });
  }

  void _stopMovementTimer() {
    _movementTimer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _movementTimer?.cancel();
    _brickMovementTimer?.cancel(); // Cancel brick movement timer
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Brick Breaker',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Score: $_score',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (FocusNode node, RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyA) {
              _isMovingLeft = true;
              _startMovementTimer();
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              _isMovingRight = true;
              _startMovementTimer();
            }
          } else if (event is RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyA) {
              _isMovingLeft = false;
              if (!_isMovingRight) {
                _stopMovementTimer();
              }
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              _isMovingRight = false;
              if (!_isMovingLeft) {
                _stopMovementTimer();
              }
            }
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: <Widget>[
            ..._brickPositions.map((position) => Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Container(
                    width: 50,
                    height: 20,
                    color: Colors.purple,
                  ),
                )),
            Positioned(
              bottom: 20,
              left: _paddlePosition,
              child: Container(
                width: 100,
                height: 20,
                color: Colors.purple,
              ),
            ),
            Positioned(
              left: _ballPosition.dx,
              top: _ballPosition.dy,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
