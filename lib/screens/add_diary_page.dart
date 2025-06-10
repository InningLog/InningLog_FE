import 'package:flutter/material.dart';

class AddDiaryPage extends StatelessWidget {
  const AddDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 일기 작성'),
      ),
      body: const Center(
        child: Text(
          '여기에 새 일기 작성 화면 내용이 들어갑니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
