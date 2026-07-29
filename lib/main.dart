import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vision_the_library/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const VisionTheLibraryApp());
}

class VisionTheLibraryApp extends StatelessWidget {
  const VisionTheLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision The Library',
      home: const WelcomeScreen(),
    );
  }
}
