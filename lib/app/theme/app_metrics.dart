import 'package:flutter/material.dart';

/// Métricas del sistema de diseño institucional TecNM.
///
/// Centraliza espaciados, radios, sombras y dimensiones para que todas las
/// pantallas compartan el mismo lenguaje visual.
abstract class AppMetrics {
  // ---- Espaciado (escala 4) ----
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Padding lateral estándar de página.
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(20, 16, 20, 28);

  // ---- Radios ----
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 26;

  /// Radio de botones.
  static const double radiusButton = 16;

  /// Radio de chips / etiquetas.
  static const double radiusChip = 12;

  // ---- Sombras (suaves, institucionales) ----
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x14101A2E), // azul-negro al 8%
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> shadowCardDark = [
    BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> shadowFloat = [
    BoxShadow(
      color: Color(0x1F101A2E), // azul-negro al 12%
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  // ---- Dimensiones ----
  static const double buttonHeight = 52;
  static const double appBarHeight = 56;
  static const double navBarHeight = 68;
  static const double logoShield = 28;
  static const double touchTarget = 44;
}
