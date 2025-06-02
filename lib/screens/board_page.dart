import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            CommonHeader(title: '커뮤니티'),

          ],
        ),
      ),
    );
  }
}

