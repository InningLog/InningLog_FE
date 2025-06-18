import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 추가!
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:inninglog/screens/splash_screen.dart';


void main() {
  runApp(const InningLogApp());
}

class InningLogApp extends StatelessWidget {
  const InningLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InningLog',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [ // 추가
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [ // 추가
        const Locale('ko', 'KR'),
      ],
      home: const SplashScreen(),
    );
  }
}
