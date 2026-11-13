import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografía oficial — Manual de Identidad Gráfica TecNM 2026 (sección 1.3).
///
/// El manual establece **Noto Sans** como tipografía a usar en cuerpos de
/// texto y documentación oficial (el TecNM debe priorizar su uso). La familia
/// se declara en `pubspec.yaml` con los pesos Regular / SemiBold / Bold.
///
/// `Patria` (títulos destacados de formatos oficiales impresos) no se incluye
/// por no estar disponible públicamente; puede añadirse como segunda familia
/// cuando se cuente con el archivo TTF distribuido por el TecNM.
class AppFonts {
  static const String family = 'NotoSans';
}

/// Jerarquía tipográfica institucional.
///
/// Los estilos no fijan color (salvo los neutros de etiquetas) para heredar el
/// color del tema activo; para casos concretos usar los helpers `of(context)`.
abstract class AppTypography {
  /// Título de pantalla / número grande (claro: 28–34).
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -.5,
  );

  /// Encabezado de sección destacada.
  static const TextStyle headline = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Título de tarjeta / elemento.
  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Texto de cuerpo.
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Texto de cuerpo con énfasis.
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Texto secundario / apoyo.
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Etiqueta de sección en mayúsculas (overline institucional).
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.2,
    color: AppColors.institutionalGray,
  );

  /// Texto de botón.
  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: .2,
  );

  /// Insignia / chip pequeño.
  static const TextStyle badge = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: .4,
    height: 1.2,
  );

  /// Micro-etiqueta (pie institucional, folios).
  static const TextStyle micro = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.3,
  );

  /// Variante para fondo oscuro (resuelve colores de texto).
  static TextStyle displayDark(Color color) =>
      display.copyWith(color: color);
}
