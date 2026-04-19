import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class BlazingFruitsApp extends StatelessWidget {
  const BlazingFruitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blazing Fruits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
