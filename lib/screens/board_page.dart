import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: '커뮤니티'),

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


