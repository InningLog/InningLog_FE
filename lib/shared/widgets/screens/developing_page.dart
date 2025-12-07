import 'package:flutter/material.dart';

void main() => runApp(DevelopingPage());

class DevelopingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Image.asset(
            'images/developing_page.png',
            fit: BoxFit.contain, // 필요에 따라 cover로 바꿔도 됨
          ),
        ),
      ),
    );
  }
}


