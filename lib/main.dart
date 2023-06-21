import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_am_speed/src/main_page.dart';

void main() {
  runApp(const MyApp());
  GoogleFonts.cabinCondensed();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white,
        )
      ),
      home: const MainPage(),
    );
  }
}
