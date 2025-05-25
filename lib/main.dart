import 'package:flutter/material.dart';
import 'package:inninglog/navigation/main_navigation.dart';

void main() {
  runApp(const InningLogApp());
}

class InningLogApp extends StatelessWidget {
  const InningLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'InningLog',
      debugShowCheckedModeBanner: false,
      home: MainNavigation(),  
    );
  }
}
