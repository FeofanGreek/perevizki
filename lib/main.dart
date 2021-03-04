import 'package:flutter/material.dart';

import 'launchScreen.dart';

String userToken, userId;

void main() {
  runApp(PerevozchikApp());
}

class PerevozchikApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: launchScreen(),
    );
  }

}