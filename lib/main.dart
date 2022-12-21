import 'package:flutter/material.dart';

import 'view/splash.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TODO List - Example',
        theme: ThemeData(
            primaryColor: Colors.deepPurple, primarySwatch: Colors.deepPurple),
        home: const SplashPage()
        //TODOPage(),
        );
  }
}
