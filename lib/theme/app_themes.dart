import 'package:flutter/material.dart';

class AppThemes {
  static const Map<String, AppThemeData> themes = {
    'elegant': AppThemeData(
      name: '素雅',
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF5F0EB), Color(0xFFEDE7E0), Color(0xFFF0EAE3)],
      ),
      surfaceColor: Color(0xFFE8E2DB),
      surfaceColorLight: Color(0xFFF0EAE3),
      accentColor: Color(0xFF5D4E37),
      accentColorDim: Color(0xFF7A6B55),
      textPrimary: Color(0xFF1E1608),
      textSecondary: Color(0xFF6E6050),
      errorColor: Color(0xFFC0392B),
      successColor: Color(0xFF27AE60),
      chipBg: Color(0xFFF2ECE5),
      chipBorder: Color(0xFFC8BFB2),
      categoryChipBg: Color(0xFFE0D8CF),
      editorBg: Color(0xFFFAF7F4),
      neonGlow: Color(0xFF5D4E37),
      shadowLight: Color(0xFFFFFFFF),
      shadowDark: Color(0xFFC0B5A8),
    ),
    'abyss': AppThemeData(
      name: '深邃',
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF080818)],
      ),
      surfaceColor: Color(0xFF0E0E24),
      surfaceColorLight: Color(0xFF161636),
      accentColor: Color(0xFF7EA0FF),
      accentColorDim: Color(0xFF5A7CE0),
      textPrimary: Color(0xFFE8ECF8),
      textSecondary: Color(0xFF8B95B8),
      errorColor: Color(0xFFE74C5F),
      successColor: Color(0xFF4ECDC4),
      chipBg: Color(0xFF141434),
      chipBorder: Color(0xFF2A2A52),
      categoryChipBg: Color(0xFF0E0E24),
      editorBg: Color(0xFF08081A),
      neonGlow: Color(0xFF7EA0FF),
      shadowLight: Color(0xFF222250),
      shadowDark: Color(0xFF030308),
    ),
    'midnight': AppThemeData(
      name: '午夜',
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
      ),
      surfaceColor: Color(0xFF1A1A2E),
      surfaceColorLight: Color(0xFF222248),
      accentColor: Color(0xFF00F5FF),
      accentColorDim: Color(0xFF00B4D8),
      textPrimary: Color(0xFFE8E8F0),
      textSecondary: Color(0xFFB0B0C8),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFF69F0AE),
      chipBg: Color(0xFF222244),
      chipBorder: Color(0xFF3A3A68),
      categoryChipBg: Color(0xFF141434),
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
      surfaceColorLight: Color(0xFF403030),
      accentColor: Color(0xFFFF6B35),
      accentColorDim: Color(0xFFE85D26),
      textPrimary: Color(0xFFF5E6D3),
      textSecondary: Color(0xFFD0B8A0),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFFFFD54F),
      chipBg: Color(0xFF3A2828),
      chipBorder: Color(0xFF6A5050),
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
      surfaceColorLight: Color(0xFF1E4430),
      accentColor: Color(0xFF69F0AE),
      accentColorDim: Color(0xFF4CAF50),
      textPrimary: Color(0xFFE8F5F0),
      textSecondary: Color(0xFFA0D8C8),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFF69F0AE),
      chipBg: Color(0xFF1E4430),
      chipBorder: Color(0xFF3A6850),
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
      surfaceColorLight: Color(0xFF303030),
      accentColor: Color(0xFFB388FF),
      accentColorDim: Color(0xFF9C64FF),
      textPrimary: Color(0xFFE8E8F0),
      textSecondary: Color(0xFFB0B0C0),
      errorColor: Color(0xFFFF5252),
      successColor: Color(0xFFB388FF),
      chipBg: Color(0xFF2E2E2E),
      chipBorder: Color(0xFF4A4A5A),
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

  bool get isLight => surfaceColor.computeLuminance() > 0.5;

  BoxDecoration raisedBox({double radius = 10, Color? color}) {
    final bg = color ?? surfaceColor;
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: shadowLight.withOpacity(isLight ? 0.8 : 0.5),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: shadowDark.withOpacity(isLight ? 0.3 : 0.8),
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
          color: shadowDark.withOpacity(isLight ? 0.25 : 0.9),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: shadowLight.withOpacity(isLight ? 0.6 : 0.3),
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
      border: border ?? Border.all(color: chipBorder.withOpacity(isLight ? 0.6 : 0.5), width: 0.8),
    );
  }

  BoxDecoration raisedButton({double radius = 8, bool active = false}) {
    return BoxDecoration(
      color: active ? accentColor.withOpacity(isLight ? 0.15 : 0.18) : surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      border: active ? Border.all(color: accentColor.withOpacity(0.6), width: 1.2) : null,
      boxShadow: active
          ? [
              BoxShadow(color: neonGlow.withOpacity(isLight ? 0.15 : 0.2), blurRadius: 8, offset: const Offset(0, 0)),
              BoxShadow(color: shadowDark.withOpacity(isLight ? 0.15 : 0.6), offset: const Offset(1, 1), blurRadius: 3),
            ]
          : [
              BoxShadow(color: shadowLight.withOpacity(isLight ? 0.7 : 0.4), offset: const Offset(-1, -1), blurRadius: 3),
              BoxShadow(color: shadowDark.withOpacity(isLight ? 0.2 : 0.7), offset: const Offset(1, 2), blurRadius: 4),
            ],
    );
  }
}
