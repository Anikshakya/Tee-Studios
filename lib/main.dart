import 'package:flutter/material.dart';
import 'tshirt_viewer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MockupStudioApp());
}

class MockupStudioApp extends StatelessWidget {
  const MockupStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D T-Shirt Mockup Studio',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111216),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF1A1C23),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MockupStudioHomePage(),
    );
  }
}

class MockupStudioHomePage extends StatelessWidget {
  const MockupStudioHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: TshirtViewer(),
      ),
    );
  }
}
