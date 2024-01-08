import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'options_screen.dart';

class GamePage extends StatefulWidget {
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  // Game state variables
  List<String> board = List.filled(9, ''); // Represents the Tic-Tac-Toe board
  String currentPlayer = 'X'; // Represents the current player ('X' or 'O')
  String statusMessage = 'Current Player: X'; // Displays the game status

  // Function to handle a tap on the game grid
  void _handleTap(int index) {
    // Check if the tapped cell is empty or if the game has already been won
    if (board[index] != '' || _checkWinner('X') || _checkWinner('O')) return;

    // Update the game state based on the tap
    setState(() {
      board[index] = currentPlayer;

      // Check for a winner
      if (_checkWinner(currentPlayer)) {
        statusMessage = '$currentPlayer Wins!';
      } else if (_isDraw()) {
        // Check for a draw
        statusMessage = 'Game is a Draw!';
      } else {
        // Switch players if the game is still ongoing
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        statusMessage = 'Current Player: $currentPlayer';
      }
    });
  }

  // Function to check if a player has won
  bool _checkWinner(String player) {
    // Check rows and columns
    for (int i = 0; i < 3; i++) {
      // Check for a win in the current row
      if ((board[i] == player && board[i + 3] == player && board[i + 6] == player) ||
          // Check for a win in the current column
          (board[i * 3] == player && board[i * 3 + 1] == player && board[i * 3 + 2] == player)) {
        // Return true if a win is found in a row or column
        return true;
      }
    }

    // Check diagonals
    if ((board[0] == player && board[4] == player && board[8] == player) ||
        (board[2] == player && board[4] == player && board[6] == player)) {
      // Return true if a win is found in a diagonal
      return true;
    }

    // Return false if no win is found
    return false;
  }

  // Function to check if the game is a draw
  bool _isDraw() {
    // Check if there are any empty cells left
    for (String cell in board) {
      if (cell.isEmpty) {
        return false;
      }
    }

    // Return true if no winner and no empty cells are found
    return !_checkWinner('X') && !_checkWinner('O');
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    Size screenSize = MediaQuery.of(context).size;

    // Calculate the width and height based on the percentage
    double gridDimension = screenSize.width < screenSize.height
        ? screenSize.width * 0.8 // Portrait or square - based on width
        : screenSize.height * 0.8; // Landscape - based on height

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
                child: Text(
                  statusMessage,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Home button
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Navigate to the main screen and remove the current screen from the stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            // Settings button
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
            // Refresh button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Reset the game state
                setState(() {
                  board = List.filled(9, '');
                  currentPlayer = 'X';
                  statusMessage = 'Current Player: $currentPlayer';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}