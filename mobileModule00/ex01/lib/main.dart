import 'package:flutter/material.dart';

void main() {
	runApp(MyApp());
}


class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext ctx) {
		return (MaterialApp(
			title:"ex01", 
			home: MyHome()
			)
		);
	}
}

class MyHome extends StatefulWidget {
	@override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String msg = "ma tekbos";
  bool helloWorld = false;

  void onPressed() {
    setState(() {
      if (helloWorld) {
        msg = "ma tekbos";
      } else {
        msg = "Hello World!";
      }
      helloWorld = !helloWorld;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              msg
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text("kbos"),
            )
          ]
        )
      )
    );
  }
}