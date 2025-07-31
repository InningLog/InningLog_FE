import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: '마이페이지'),
            Expanded(
              child: Image.asset(
                'assets/images/developing_image.jpg',
                width: 274,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

