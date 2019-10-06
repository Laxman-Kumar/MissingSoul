import 'package:flutter/material.dart';
import 'package:missingperson/Views/dashboard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Missing Soul',
      home: Dashboard()
    );
  }
}

