import 'package:flutter/material.dart';
import '../main.dart';
import 'main_screen.dart';

class OptionsScreen extends StatefulWidget {
  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    // Set the default value based on the current theme
    _selectedTheme = MyApp.of(context)?.getIsDarkMode() == true ? 'Dark' : 'Light';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Theme:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Label
            DropdownButton<String>(
              value: _selectedTheme,
              items: <String>['Dark', 'Light']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTheme = newValue!;
                  MyApp.of(context)!.toggleTheme(_selectedTheme == 'Dark');
                });
            },
        ),
        ],
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
        ],
      ),
    ),
    );
    
  }
}