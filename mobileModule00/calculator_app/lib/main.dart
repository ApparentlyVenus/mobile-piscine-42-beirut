import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: "Calculator App",
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String expr = "0";
  String result = "0";

  void onPressed(String button) {
    setState(() {
      if (button == "AC") {
        expr = "0";
        result = "0";
      } else if (button == "C") {
          if (expr.length > 1) {
            expr = expr.substring(0, expr.length - 1);
          } else {
            expr = "0";
          }
      } else if (button == "=") {
        try {
          if (expr.contains('/0')) {
            result = "Error: Div by 0";
          } else {
            result = calculate(expr);
          }
        } catch (e) {
          result = "Error";
        } 
      } else {
        if (expr == "0") {
          expr = button;
        } else {
          expr += button;
        }
      }
    });
  } 

  String calculate(String expr) {
    try {
      Parser p = Parser();
      Expression parsedExpr = p.parse(expr);
      ContextModel cm = ContextModel();
      double eval = parsedExpr.evaluate(EvaluationType.REAL, cm);
      
      if (eval.isInfinite) {
        return "Error: Infinity";
      }
      if (eval.isNaN) {
        return "Error: NaN";
      }
      if (eval.abs() > 1e15) {
        return eval.toStringAsExponential(2);  
      }
      if (eval == eval.toInt()) {
        return eval.toInt().toString();
      } else {
        return eval.toStringAsFixed(5);
      }
    } catch (e) {
      return "Error";
    }
  }

  Widget buildButton(String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => onPressed(text),
        child: Text(text, style: TextStyle(fontSize: 20)),
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
                  Text(expr, style: TextStyle(fontSize: 24)),
                  Text(result, style: TextStyle(fontSize: 48)),
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



