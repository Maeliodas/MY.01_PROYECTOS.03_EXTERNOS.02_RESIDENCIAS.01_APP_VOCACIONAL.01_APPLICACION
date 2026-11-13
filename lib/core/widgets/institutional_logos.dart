import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Logotipos institucionales oficiales (TecNM e ITTUX), usados tal cual desde
/// `assets/institution/`: sin fondos añadidos, sin recolorear ni regenerar.
///
/// Los mismos archivos se emplean en claro y en oscuro (decisión de producto):
/// la tinta azul del TecNM (`LOGO-TECNM-una-linea-azul`, `LOGO-VERTICAL-TECNM`)
/// se usa directamente sobre el fondo, en ambos modos. `tecnm.png` (emblema)
/// queda disponible para usos futuros.
abstract class InstitutionalLogos {
  static const String wordmarkLine =
      'assets/institution/LOGO-TECNM-una-linea-azul.png';
  static const String wordmarkVertical =
      'assets/institution/LOGO-VERTICAL-TECNM.png';
  static const String emblem = 'assets/institution/tecnm.png';
  static const String ittux = 'assets/institution/ITTUX.png';

  /// Escudo del instituto (autoiluminado, válido en claro y oscuro).
  static Widget mark({double height = 34}) =>
      Image.asset(ittux, height: height, fit: BoxFit.contain);
}

/// Divisor vertical entre marcas (hairline institucional).
class _InstitutionalDivider extends StatelessWidget {
  final double height;
  final bool dark;
  const _InstitutionalDivider({required this.height, required this.dark});

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: height,
        color: dark ? AppColors.borderDark : AppColors.gray300,
      );
}

/// Composición horizontal oficial: marca TecNM + divisor + escudo ITTUX.
/// Idéntica en claro y oscuro (mismos archivos oficiales).
class InstitutionalLockup extends StatelessWidget {
  final double scale;
  final bool showDivider;

  const InstitutionalLockup({
    super.key,
    this.scale = 1,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final escudo = 60 * scale;
    final tecnm = 33 * scale;
    final gap = 18 * scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          InstitutionalLogos.wordmarkLine,
          height: tecnm,
          fit: BoxFit.contain,
        ),
        if (showDivider) ...[
          SizedBox(width: gap),
          _InstitutionalDivider(height: escudo * .68, dark: dark),
          SizedBox(width: gap),
        ],
        Image.asset(
          InstitutionalLogos.ittux,
          height: escudo,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

/// Composición destacada (splash): logotipo vertical oficial del TecNM +
/// escudo ITTUX. Idéntica en claro y oscuro.
class InstitutionalHero extends StatelessWidget {
  final double scale;

  const InstitutionalHero({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final escudo = 94 * scale;
    final tecnm = 150 * scale;
    final gap = 24 * scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          InstitutionalLogos.wordmarkVertical,
          height: tecnm,
          fit: BoxFit.contain,
        ),
        SizedBox(width: gap),
        _InstitutionalDivider(height: escudo * .78, dark: dark),
        SizedBox(width: gap),
        Image.asset(
          InstitutionalLogos.ittux,
          height: escudo,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

/// Pie institucional reutilizable: lockup + nombres oficiales + leyenda.
/// Los logotipos son los mismos en claro y oscuro.
class InstitutionalFooter extends StatelessWidget {
  final String? caption;
  final double scale;
  final bool showNames;

  const InstitutionalFooter({
    super.key,
    this.caption,
    this.scale = 1,
    this.showNames = true,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final namesColor = dark
        ? AppColors.textSecondaryDark
        : AppColors.institutionalGray;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 210 * scale,
          height: 1,
          margin: EdgeInsets.only(bottom: 16 * scale),
          color: dark ? AppColors.borderDark : AppColors.gray300,
        ),
        InstitutionalLockup(scale: scale),
        if (caption != null) ...[
          SizedBox(height: 8 * scale),
          Text(
            caption!,
            textAlign: TextAlign.center,
            style: AppTypography.micro.copyWith(
              letterSpacing: 1.4,
              color: namesColor,
            ),
          ),
        ],
      ],
    );
  }
}
