import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'main_screen.dart';
import 'options_screen.dart';

class Player {
  String name;
  int numWins;

  Player({required this.name, required this.numWins});
}

class SinglePlayerGamePage extends StatefulWidget {
  @override
  SinglePlayerGamePageState createState() => SinglePlayerGamePageState();
}

class SinglePlayerGamePageState extends State<SinglePlayerGamePage> {
  Player currentPlayer = Player(name: 'Player X', numWins: 0);
  List<String> board = List.filled(9, '');
  String statusMessage = 'Current Player: X';
  bool isAITurn = false;
  int countdown = 3;
  bool isCountdownActive = true;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // cancel the timer to avoid calling setState after dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double gridDimension = screenSize.width < screenSize.height
        ? screenSize.width * 0.8
        : screenSize.height * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StarWars TicTacToe'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: gridDimension,
            maxHeight: gridDimension,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(3.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => _handleTap(index),
                      child: GridTile(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: Center(
                            child: board[index].isEmpty
                                ? null
                                : Image.asset(
                                    'assets/icons/${board[index]}.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Player: ${currentPlayer.name}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Wins: ${currentPlayer.numWins}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      statusMessage,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (isCountdownActive)
                Text(
                  'Next round starts in $countdown seconds',
                  style: TextStyle(fontSize: 18),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OptionsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Allow restarting only when the countdown is not active
                if (!isCountdownActive) {
                  _startNewRound();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(int index) {
    // Allow tapping only when it's the player's turn and the countdown is not active
    if (!isAITurn && !isCountdownActive) {
      if (board[index] == '' && !_checkWinner('X') && !_checkWinner('O') && !_isDraw()) {
        // Update the game state based on the player's move
        _makeMove(index, 'X');

        // Check for a winner or draw
        _checkGameResult();

        // Set the flag to true to indicate it's now the AI's turn
        isAITurn = true;

        // Add a delay before the AI's move (for authenticity)
        Future.delayed(Duration(seconds: 1), () {
          // Check again if the game is still ongoing before making the AI move
          if (!_checkWinner('X') && !_checkWinner('O') && !_isDraw()) {
            // Get the AI's move
            int aiMove = _getAIMove();

            // Update the game state based on the AI's move
            _makeMove(aiMove, 'O');

            // Check for a winner or draw after the AI's move
            _checkGameResult();

            // Set the flag to false to indicate it's now the player's turn
            isAITurn = false;
          }
        });
      }
    }
  }

  void _makeMove(int index, String player) {
    setState(() {
      board[index] = player;
    });
  }

  void _checkGameResult() {
    if (_checkWinner('X')) {
      statusMessage = '${currentPlayer.name} Wins!';
      _saveWinsToCSV(); // Save wins to CSV
      setState(() {
        currentPlayer.numWins++;
      });
      _startNewRound();
    } else if (_checkWinner('O')) {
      statusMessage = 'AI Wins!';
      _startNewRound();
    } else if (_isDraw()) {
      statusMessage = 'Game is a Draw!';
      _startNewRound();
    }
  }

  bool _checkWinner(String player) {
    // Check rows, columns, and diagonals for a winner
    for (int i = 0; i < 3; i++) {
      if (board[i * 3] == player && board[i * 3 + 1] == player && board[i * 3 + 2] == player) {
        return true; // Check rows
      }
      if (board[i] == player && board[i + 3] == player && board[i + 6] == player) {
        return true; // Check columns
      }
    }
    if (board[0] == player && board[4] == player && board[8] == player) {
      return true; // Check diagonal \
    }
    if (board[2] == player && board[4] == player && board[6] == player) {
      return true; // Check diagonal /
    }
    return false;
  }

  bool _isDraw() {
    // Check if the board is full
    return !board.contains('');
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        setState(() {
          isCountdownActive = false;
        });
        timer.cancel(); // stop the countdown timer
      }
    });
  }

  void _startNewRound() {
    setState(() {
      board = List.filled(9, '');
      isCountdownActive = true;
      countdown = 3;
      _startCountdown();
    });
  }

  int _getAIMove() {
    // Simple AI logic: make a random move
    List<int> availableMoves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        availableMoves.add(i);
      }
    }
    if (availableMoves.isNotEmpty) {
      return availableMoves[Random().nextInt(availableMoves.length)];
    }
    return -1; // No available moves (should not happen if the game is checked for a draw before calling this)
  }

  void _saveWinsToCSV() async {
    List<List<dynamic>> rows = [];

    // Read existing CSV content if the file exists
    File file = File(await _getFilePath());
    bool fileExists = await file.exists();

    // Add existing rows to the data to be saved
    if (fileExists) {
      String content = await file.readAsString();
      List<List<dynamic>> existingRows = CsvToListConverter().convert(content);
      rows.addAll(existingRows);
    }

    // Add the current player's wins to the CSV data
    rows.add([currentPlayer.name, currentPlayer.numWins]);

    // Convert the data to CSV format
    String csvContent = ListToCsvConverter().convert(rows);

    // Write the content to the CSV file
    await file.writeAsString(csvContent);
  }

  // Helper method to get the file path for the CSV file
  Future<String> _getFilePath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/player_wins.csv';
  }
}
