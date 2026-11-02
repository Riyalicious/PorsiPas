import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const PorsiPasApp());
}

class PorsiPasApp extends StatelessWidget {
  const PorsiPasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PorsiPas AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        fontFamily: 'Sans-Serif',
      ),
      home: const MainNavigationScreen(),
    );
  }
}