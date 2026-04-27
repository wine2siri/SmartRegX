import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/tag_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const XiaobaiRegexApp());
}

class XiaobaiRegexApp extends StatelessWidget {
  const XiaobaiRegexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TagProvider()..loadTags(),
      child: Consumer<TagProvider>(
        builder: (context, provider, _) {
          final themeData = AppThemes.themes[provider.theme] ?? AppThemes.themes['midnight']!;
          return MaterialApp(
            title: '小白正则',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.transparent,
              colorSchemeSeed: themeData.accentColor,
              brightness: Brightness.dark,
              useMaterial3: true,
              fontFamily: null,
            ),
            home: HomeScreen(themeData: themeData),
          );
        },
      ),
    );
  }
}
