import 'package:flutter/material.dart';

// ============================================================
// THEME & CONSTANTS
// ============================================================

class AppTheme {
  static const Color primary    = Color(0xFF1565C0);
  static const Color bgLight    = Color(0xFFF2F4F7);
  static const Color bgCard     = Colors.white;
  static const Color textDark   = Color(0xFF1A1A2E);
  static const Color textMuted  = Color(0xFF6B7280);
  static const Color correct    = Color(0xFF22C55E);
  static const Color wrong      = Color(0xFFEF4444);
  static const Color accent     = Color(0xFFFF6B35);

  // Subject card colors — vivid, distinct palette
  static const List<Color> subjectColors = [
    Color(0xFF1565C0), // Toán - deep blue
    Color(0xFFD81B60), // Vật lý - magenta
    Color(0xFF2E7D32), // Hoá - forest green
    Color(0xFF00838F), // Anh - teal
    Color(0xFF6A1B9A), // Sinh - purple
    Color(0xFF0277BD), // Địa - sky blue
    Color(0xFFE65100), // Lịch sử - deep orange
    Color(0xFFF57F17), // GDCD - amber
    Color(0xFF283593), // Ngữ văn - indigo
    Color(0xFF00695C), // SGK - dark teal
  ];

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: bgLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    ),
  );
}
