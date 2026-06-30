import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ❌ ลบคำสั่ง MusicService().startMusic(); ออกจากตรงนี้

  runApp(const MixtailApp());
}

class MixtailApp extends StatelessWidget {
  const MixtailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mixtail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF222222),
        fontFamily: 'PixelFont',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
