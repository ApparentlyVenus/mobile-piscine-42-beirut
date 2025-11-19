import 'package:flutter/material.dart';

void main() {
	runApp(MyApp());
}


class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext ctx) {
		return (MaterialApp(
			title:"ex00", 
			home: MyHome()
			)
		);
	}
}

class MyHome extends StatelessWidget {
	@override
  	Widget build(BuildContext ctx)
	{
    	return (Scaffold(
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						const Text("Odana's ex00"),
						const SizedBox(height: 20),
						ElevatedButton(
							onPressed: () {
								print("Button Pressed");
						},
							child: const Text("Click me"),
							)
						],
					),
				),
			)
		);
	}
}