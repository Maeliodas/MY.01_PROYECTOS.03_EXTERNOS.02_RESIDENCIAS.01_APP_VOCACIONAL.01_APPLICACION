import 'package:flutter/material.dart';

/// Paleta institucional basada en Manual de Identidad Gráfica TecNM 2026
/// Secciones 2.3 / 2.4 / 2.5 — solo azul.
///
/// Fuente:
/// - Pantone 294 C
/// - CMYK: C100 M85 Y30 K20
/// - RGB: R27 G57 B106
/// - HEX: #1B396A
class AppColors {
  // Azul primario institucional TecNM (Pantone 294 C)
  static const Color primary = Color(0xFF1B396A);
  static const Color primaryDark = Color(0xFF132A4F);
  static const Color primaryDarker = Color(0xFF0F2340);
  static const Color primaryLight = Color(0xFFD9E2EF);
  static const Color primaryLighter = Color(0xFFEEF2F7);

  // Escala monocromática derivada de #1B396A
  static const Color blue50 = Color(0xFFEEF2F7);
  static const Color blue100 = Color(0xFFD9E2EF);
  static const Color blue200 = Color(0xFFB3C5DD);
  static const Color blue300 = Color(0xFF84A3C8);
  static const Color blue400 = Color(0xFF4A7AB0);
  static const Color blue500 = Color(0xFF1B396A);
  static const Color blue600 = Color(0xFF17325E);
  static const Color blue700 = Color(0xFF132A4F);
  static const Color blue800 = Color(0xFF0F2340);
  static const Color blue900 = Color(0xFF0B1A30);

  // Secundario armónico (solo familia azul)
  static const Color secondary = Color(0xFF2F6AAE);
  static const Color secondaryDark = Color(0xFF1D5A94);
  static const Color secondaryLight = Color(0xFFDCE9F8);

  // Fondos responsivos claro / oscuro (tinte azul, no verde)
  static const Color background = Color(0xFFF1F5FA);
  static const Color backgroundDark = Color(0xFF0B1526);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF111E33);
  static const Color surfaceVariant = Color(0xFFE8EFF7);
  static const Color surfaceVariantDark = Color(0xFF1A2A45);

  // Acentos de tarjetas / tags — solo azules
  static const Color accentBlue = Color(0xFF2F6AAE);
  static const Color lightBlueMatch = Color(0xFFDCE9F8);
  static const Color textBlueMatch = Color(0xFF1B396A);

  // Segundo acento frío dentro de la misma familia (reemplaza morado)
  static const Color accentSteel = Color(0xFF5A8AC0);
  static const Color lightSteelMatch = Color(0xFFE6EEF8);
  static const Color textSteelMatch = Color(0xFF2C4A73);

  // Compatibilidad: antes accentPurple, ahora mapeado a acero azulado
  static const Color accentPurple = Color(0xFF5A8AC0);
  static const Color lightPurpleMatch = Color(0xFFE6EEF8);
  static const Color textPurpleMatch = Color(0xFF2C4A73);

  // Grises fríos y textos
  static const Color textPrimary = Color(0xFF1A2333);
  static const Color textSecondary = Color(0xFF5B6B82);
  static const Color textPrimaryDark = Color(0xFFEAF0F8);
  static const Color textSecondaryDark = Color(0xFFA9B8CE);
  static const Color borderGray = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF2A3B55);

  static const Color destructiveRed = Color(0xFFDC2626);
  static const Color logoutBg = Color(0xFFFEE2E2);

  // Sobre primario azul siempre blanco (contraste AA)
  static const Color onPrimary = Color(0xFFFFFFFF);

  // --- Aliases de compatibilidad ---
  static const Color textGrey = textSecondary;
  static const Color textLightGrey = borderGray;
  static const Color primaryGreen = primary;
  static const Color primaryGreenLight = primaryLight;
  static const Color primaryDarkGreen = primaryDark;
  static const Color error = destructiveRed;
  static const Color card = cardBackground;
}
