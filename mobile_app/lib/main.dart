import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyanvruksh/screens/login.dart';

void main() {
  runApp(const GyanvrukshApp());
}

class GyanvrukshApp extends StatelessWidget {
  const GyanvrukshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyanvruksh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3C6EFA), // Blue
          secondary: Color(0xFFA58DF5), // Purple
          tertiary: Color(0xFF26A69A), // Teal
          surface: Colors.white, // Soft gray background
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const LoginScreen(),
      // For quick testing, you can set home: const DashboardScreen(),
    );
  }
}
