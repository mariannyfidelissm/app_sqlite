import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'todo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  splash() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const TODOPage()));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      splash();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          Container(color: const Color.fromARGB(255, 241, 239, 239)),
          Center(
            child: Lottie.asset(
              //'https://assets8.lottiefiles.com/packages/lf20_HX0isy.json',
              "assets/animation.json",
              repeat: true,
              reverse: true,
              animate: true,
            ),
          ),
        ],
      ),
    );
  }
}
