import 'package:flutter/material.dart';

class AppThemes {
  static const Map<String, AppThemeData> themes = {
    'midnight': AppThemeData(
      name: '午夜',
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
      ),
      surfaceColor: Color(0xFF1A1A2E),
      surfaceColorLight: Color(0xFF16213E),
      accentColor: Color(0xFF00F5FF),
      accentColorDim: Color(0xFF00B4D8),
      textPrimary: Color(0xFFE0E0E0),
      textSecondary: Color(0xFF9E9E9E),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFF69F0AE),
      chipBg: Color(0xFF1E293B),
      chipBorder: Color(0xFF334155),
      categoryChipBg: Color(0xFF0F172A),
      editorBg: Color(0xFF0D1117),
      neonGlow: Color(0xFF00F5FF),
      shadowLight: Color(0xFF3A3570),
      shadowDark: Color(0xFF0A0820),
    ),
    'ember': AppThemeData(
      name: '余烬',
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A0A0A), Color(0xFF2D1B1B), Color(0xFF1A0A0A)],
      ),
      surfaceColor: Color(0xFF2D1B1B),
      surfaceColorLight: Color(0xFF3D2B2B),
      accentColor: Color(0xFFFF6B35),
      accentColorDim: Color(0xFFE85D26),
      textPrimary: Color(0xFFF5E6D3),
      textSecondary: Color(0xFFBFA88F),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFFFFD54F),
      chipBg: Color(0xFF3D2B2B),
      chipBorder: Color(0xFF5D4B4B),
      categoryChipBg: Color(0xFF2D1B1B),
      editorBg: Color(0xFF1A0A0A),
      neonGlow: Color(0xFFFF6B35),
      shadowLight: Color(0xFF4D3B3B),
      shadowDark: Color(0xFF100505),
    ),
    'aurora': AppThemeData(
      name: '极光',
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1628), Color(0xFF0D2818), Color(0xFF0A1628)],
      ),
      surfaceColor: Color(0xFF0D2818),
      surfaceColorLight: Color(0xFF1A3A28),
      accentColor: Color(0xFF69F0AE),
      accentColorDim: Color(0xFF4CAF50),
      textPrimary: Color(0xFFE0F2F1),
      textSecondary: Color(0xFF80CBC4),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFF69F0AE),
      chipBg: Color(0xFF1A3A28),
      chipBorder: Color(0xFF2E5A3E),
      categoryChipBg: Color(0xFF0D2818),
      editorBg: Color(0xFF0A1628),
      neonGlow: Color(0xFF69F0AE),
      shadowLight: Color(0xFF2A4A38),
      shadowDark: Color(0xFF050F0A),
    ),
    'void': AppThemeData(
      name: '虚空',
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
      ),
      surfaceColor: Color(0xFF1A1A1A),
      surfaceColorLight: Color(0xFF2A2A2A),
      accentColor: Color(0xFFB388FF),
      accentColorDim: Color(0xFF9C64FF),
      textPrimary: Color(0xFFE0E0E0),
      textSecondary: Color(0xFF9E9E9E),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFFB388FF),
      chipBg: Color(0xFF2A2A2A),
      chipBorder: Color(0xFF3A3A3A),
      categoryChipBg: Color(0xFF1A1A1A),
      editorBg: Color(0xFF0A0A0A),
      neonGlow: Color(0xFFB388FF),
      shadowLight: Color(0xFF3A3A3A),
      shadowDark: Color(0xFF050505),
    ),
  };
}

class AppThemeData {
  final String name;
  final LinearGradient background;
  final Color surfaceColor;
  final Color surfaceColorLight;
  final Color accentColor;
  final Color accentColorDim;
  final Color textPrimary;
  final Color textSecondary;
  final Color errorColor;
  final Color successColor;
  final Color chipBg;
  final Color chipBorder;
  final Color categoryChipBg;
  final Color editorBg;
  final Color neonGlow;
  final Color shadowLight;
  final Color shadowDark;

  const AppThemeData({
    required this.name,
    required this.background,
    required this.surfaceColor,
    required this.surfaceColorLight,
    required this.accentColor,
    required this.accentColorDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.errorColor,
    required this.successColor,
    required this.chipBg,
    required this.chipBorder,
    required this.categoryChipBg,
    required this.editorBg,
    required this.neonGlow,
    required this.shadowLight,
    required this.shadowDark,
  });

  BoxDecoration raisedBox({double radius = 10, Color? color}) {
    final bg = color ?? surfaceColor;
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: shadowLight.withOpacity(0.5),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: shadowDark.withOpacity(0.8),
          offset: const Offset(2, 2),
          blurRadius: 6,
        ),
      ],
    );
  }

  BoxDecoration insetBox({double radius = 10, Color? color}) {
    final bg = color ?? surfaceColor;
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: shadowDark.withOpacity(0.9),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: shadowLight.withOpacity(0.3),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
      ],
    );
  }

  BoxDecoration flatBox({double radius = 8, Color? color, Border? border}) {
    final bg = color ?? chipBg;
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(color: chipBorder.withOpacity(0.3), width: 0.5),
    );
  }

  BoxDecoration raisedButton({double radius = 8, bool active = false}) {
    return BoxDecoration(
      color: active ? accentColor.withOpacity(0.15) : surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      border: active ? Border.all(color: accentColor.withOpacity(0.5), width: 1) : null,
      boxShadow: active
          ? [
              BoxShadow(color: neonGlow.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 0)),
              BoxShadow(color: shadowDark.withOpacity(0.6), offset: const Offset(1, 1), blurRadius: 3),
            ]
          : [
              BoxShadow(color: shadowLight.withOpacity(0.4), offset: const Offset(-1, -1), blurRadius: 3),
              BoxShadow(color: shadowDark.withOpacity(0.7), offset: const Offset(1, 2), blurRadius: 4),
            ],
    );
  }
}
