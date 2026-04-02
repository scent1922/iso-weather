import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

class IsoWeatherApp extends StatelessWidget {
  const IsoWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minicast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
