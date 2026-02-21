import 'package:flutter/material.dart';
import 'ui/app_theme.dart';
import 'features/library/library_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HiFiPlayerApp());
}

class HiFiPlayerApp extends StatelessWidget {
  const HiFiPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const LibraryPage(),
    );
  }
}