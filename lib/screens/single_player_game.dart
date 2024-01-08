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
    _startCountdown(); // Start the initial countdown when the widget is created
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // Cancel the timer to avoid calling setState after dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the size of the grid based on the screen dimensions
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
                  // Widget to build the TicTacToe grid
                  // (InkWell is used for handling taps on individual cells)
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
              // Display player information and game status
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
              // Display the countdown only when it is active
              if (isCountdownActive)
                Text(
                  'Next round starts in $countdown seconds',
                  style: TextStyle(fontSize: 18),
                ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar with home, settings, and restart buttons
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Navigate to the main screen and remove this screen from the stack
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
                // Navigate to the options screen
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

  // Handle the tap event on the TicTacToe grid
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

  // Update the game state with the player's move
  void _makeMove(int index, String player) {
    setState(() {
      board[index] = player;
    });
  }

  // Check the game result (win, lose, or draw)
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

  // Check if a player has won
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

  // Check if the game is a draw
  bool _isDraw() {
    // Check if the board is full
    return !board.contains('');
  }

  // Start the countdown timer
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
        timer.cancel(); // Stop the countdown timer
      }
    });
  }

  // Start a new round of the game
  void _startNewRound() {
    setState(() {
      board = List.filled(9, '');
      isCountdownActive = true;
      countdown = 3;
      _startCountdown(); // Start the countdown for the new round
    });
  }

  // Get the AI's move (simple logic: make a random move)
  int _getAIMove() {
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

  // Save player wins to a CSV file
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