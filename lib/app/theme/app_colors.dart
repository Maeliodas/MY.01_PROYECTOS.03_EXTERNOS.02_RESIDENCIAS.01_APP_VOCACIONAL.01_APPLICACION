import 'package:flutter/material.dart';

/// Paleta institucional — Manual de Identidad Gráfica TecNM 2026 (sección 2.3)
///
/// Colores oficiales:
/// - Azul institucional   · Pantone 294 C        · R27 G57 B106  · #1B396A
/// - Gris institucional   · Pantone Cool Gray 10 C · R128 G127 B131 · #807E82
/// - Negro                · 100% K               · #000000
///
/// Las tonalidades derivadas (escala azul, neutros claros/oscuros) son
/// decisiones de diseño para la interfaz, no colores oficiales del manual.
class AppColors {
  // ---- Colores oficiales del manual ----
  static const Color primary = Color(0xFF1B396A); // Pantone 294 C
  static const Color institutionalGray = Color(0xFF807E82); // Cool Gray 10 C
  static const Color institutionalBlack = Color(0xFF000000);

  // ---- Escala derivada del azul institucional (tonos de diseño) ----
  static const Color blue50 = Color(0xFFF0F4FA);
  static const Color blue100 = Color(0xFFDCE5F1);
  static const Color blue200 = Color(0xFFB9C9DE);
  static const Color blue300 = Color(0xFF8FA9C9);
  static const Color blue400 = Color(0xFF5A7FAF);
  static const Color blue500 = Color(0xFF1B396A); // azul institucional
  static const Color blue600 = Color(0xFF17325E);
  static const Color blue700 = Color(0xFF132A4F);
  static const Color blue800 = Color(0xFF0F2140);
  static const Color blue900 = Color(0xFF0A172B);

  // Azul de acción secundaria (misma familia, tono medio)
  static const Color secondary = Color(0xFF2F6AAE);
  static const Color secondaryDark = Color(0xFF265A94);
  static const Color secondaryLight = Color(0xFFE3EDF8);

  // ---- Neutros (blancos y grises para fondos, superficies y divisores) ----
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF7F8FA);
  static const Color gray100 = Color(0xFFF1F3F6);
  static const Color gray200 = Color(0xFFE3E7ED);
  static const Color gray300 = Color(0xFFCBD1DA);
  static const Color gray400 = Color(0xFFA6ADB8);
  static const Color gray500 = Color(0xFF807E82); // gris institucional
  static const Color gray600 = Color(0xFF66686D);
  static const Color gray700 = Color(0xFF4A4C51);
  static const Color gray800 = Color(0xFF2E3136);
  static const Color gray900 = Color(0xFF17191C);

  // ---- Tokens del tema claro ----
  static const Color background = Color(0xFFF4F6F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE9EDF3);
  static const Color borderGray = Color(0xFFE1E6EE);
  static const Color textPrimary = Color(0xFF10151C);
  static const Color textSecondary = Color(0xFF5D646E);

  // ---- Tokens del tema oscuro (azul-negro neutro, nunca azul dominante) ----
  static const Color backgroundDark = Color(0xFF0E141B);
  static const Color cardBackgroundDark = Color(0xFF151C26);
  static const Color surfaceVariantDark = Color(0xFF1D2531);
  static const Color borderDark = Color(0xFF2A3442);
  static const Color textPrimaryDark = Color(0xFFE8EDF3);
  static const Color textSecondaryDark = Color(0xFF9AA4B0);

  // Azul institucional aclarado para conservar contraste sobre oscuro.
  static const Color primaryOnDark = Color(0xFF6E95C9);
  static const Color primaryOnDarkContainer = Color(0xFF1A2A45);

  // ---- Estados funcionales ----
  static const Color destructiveRed = Color(0xFFDC2626);
  static const Color destructiveBg = Color(0xFFFEE2E2);
  static const Color destructiveBgDark = Color(0xFF3B1A1A);

  // Sobre el azul primario siempre blanco (contraste AA).
  static const Color onPrimary = Color(0xFFFFFFFF);

  // --- Aliases de compatibilidad (no eliminar: usados en pantallas) ---
  static const Color primaryDark = Color(0xFF17325E);
  static const Color primaryDarker = Color(0xFF0F2140);
  static const Color primaryLight = Color(0xFFDCE5F1);
  static const Color primaryLighter = Color(0xFFF0F4FA);
  static const Color accentBlue = Color(0xFF2F6AAE);
  static const Color lightBlueMatch = Color(0xFFE3EDF8);
  static const Color textBlueMatch = Color(0xFF1B396A);
  static const Color accentSteel = Color(0xFF5A7FAF);
  static const Color lightSteelMatch = Color(0xFFE9EEF6);
  static const Color textSteelMatch = Color(0xFF17325E);
  static const Color accentPurple = Color(0xFF5A7FAF);
  static const Color lightPurpleMatch = Color(0xFFE9EEF6);
  static const Color textPurpleMatch = Color(0xFF17325E);
  static const Color textGrey = textSecondary;
  static const Color textLightGrey = borderGray;
  static const Color primaryGreen = primary;
  static const Color primaryGreenLight = primaryLight;
  static const Color primaryDarkGreen = primaryDark;
  static const Color error = destructiveRed;
  static const Color logoutBg = destructiveBg;
  static const Color card = cardBackground;
}
