import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BrickBreaker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  Timer? _timer; // Timer for the game loop
  Timer? _movementTimer; // Timer for paddle movement
  Timer? _brickMovementTimer; // Timer for moving bricks down

  bool _isMovingLeft = false; // Flag to check if paddle is moving left
  bool _isMovingRight = false; // Flag to check if paddle is moving right
  bool _isGameStarted = false; // Flag to check if the game has started

  List<Offset> _brickPositions = []; // List to store brick positions

  double _paddlePosition = 0.0; // Position of the paddle
  Offset _ballPosition = Offset(0, 0); // Position of the ball
  Offset _ballVelocity = Offset(2, 2); // Velocity of the ball

  FocusNode _focusNode = FocusNode(); // Focus node for keyboard input

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
      if (!_isGameStarted) return;
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
          _showGameOverDialog();
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
          _showGameOverDialog();
        }

        if (_brickPositions.isEmpty) {
          _timer?.cancel();
          _brickMovementTimer?.cancel(); // Stop brick movement
          _showVictoryDialog();
        }
      });
    });
  }

  void _startBrickMovement() {
    _brickMovementTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!_isGameStarted) return;
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

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('You lost! Your score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/profile');
            },
            child: Text('Exit Game'),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Victory'),
        content: Text('Your score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/profile');
            },
            child: Text('Exit Game'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _isGameStarted = false;
      _brickPositions.clear();
      _initializeBricks();
      _paddlePosition = (MediaQuery.of(context).size.width - 100) / 2;
      _ballPosition = Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height -
              300); // Ball spawns above the paddle
      _ballVelocity = Offset(2, 2); // Reset ball velocity
    });
    _startGameLoop();
    _startBrickMovement();
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
            if (!_isGameStarted)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isGameStarted = true;
                    });
                    _startGameLoop();
                    _startBrickMovement();
                  },
                  child: Text('Start Game'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
