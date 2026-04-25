import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tag_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const XiaobaiRegexApp());
}

class XiaobaiRegexApp extends StatelessWidget {
  const XiaobaiRegexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TagProvider()..loadTags(),
      child: MaterialApp(
        title: '小白正则',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF6750A4),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF6750A4),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
