import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: "ex02",
      home: Calculator(),
    );
  }
}

class Calculator extends StatelessWidget {
  
  Widget buildButton(String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => print(text),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("0", style: TextStyle(fontSize: 24)),
                  Text("0", style: TextStyle(fontSize: 48)),
                ],
              ),
            ),
          ),
          
          // Buttons
          Expanded(
            child: Column(
              children: [
                Expanded(child: Row(children: [buildButton("AC"), buildButton("C"), buildButton("/"), buildButton("*")])),
                Expanded(child: Row(children: [buildButton("7"), buildButton("8"), buildButton("9"), buildButton("-")])),
                Expanded(child: Row(children: [buildButton("4"), buildButton("5"), buildButton("6"), buildButton("+")])),
                Expanded(child: Row(children: [buildButton("1"), buildButton("2"), buildButton("3"), buildButton("=")])),
                Expanded(child: Row(children: [buildButton("0"), buildButton("."), Expanded(child: Container()), Expanded(child: Container())])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


