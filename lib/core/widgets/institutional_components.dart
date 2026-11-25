import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';
import '../../app/theme/app_typography.dart';
import 'institutional_logos.dart';

/// Encabezado de página institucional.
///
/// Composición: título (jerarquía `headline`), subtítulo opcional y espacio
/// para el escudo institucional (`showInstitutionalMark`) o un widget propio.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showInstitutionalMark;

  /// Barra de acento vertical (recurso de membrete oficial). Se puede
  /// desactivar cuando el título ya va anclado a otro elemento fuerte.
  final bool accentBar;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showInstitutionalMark = false,
    this.accentBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final accent = dark ? AppColors.primaryOnDark : AppColors.primary;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headline.copyWith(color: titleColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTypography.caption.copyWith(color: subtitleColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (accentBar) ...[
          Container(
            width: 4,
            height: subtitle != null ? 42 : 30,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppMetrics.md),
        ],
        Expanded(child: titleBlock),
        if (trailing != null) ...[
          const SizedBox(width: AppMetrics.sm),
          trailing!,
        ] else if (showInstitutionalMark) ...[
          const SizedBox(width: AppMetrics.sm),
          InstitutionalLogos.mark(height: 34),
        ],
      ],
    );
  }
}

/// Etiqueta de sección en mayúsculas (jerarquía institucional).
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: dark ? AppColors.primaryOnDark : AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: AppTypography.sectionLabel.copyWith(
            color: dark ? AppColors.primaryOnDark : AppColors.institutionalGray,
          ),
        ),
      ],
    );
  }
}

/// Banda membrete institucional: franja en azul oficial con la línea de
/// identificación en blanco, al estilo de los documentos del TecNM.
class InstitutionalBand extends StatelessWidget {
  final String text;
  final double height;

  const InstitutionalBand({
    super.key,
    this.text =
        'TECNOLÓGICO NACIONAL DE MÉXICO · INSTITUTO TECNOLÓGICO DE TUXTEPEC',
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.primary,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          style: AppTypography.micro.copyWith(
            fontSize: 9.5,
            letterSpacing: 2,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// Tarjeta institucional (superficie, radio y sombra unificados).
class InstitutionalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  const InstitutionalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppMetrics.lg),
    this.margin,
    this.radius = AppMetrics.radiusLg,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? Theme.of(context).colorScheme.surface;
    final card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: dark ? Border.all(color: AppColors.borderDark) : null,
        boxShadow: dark ? AppMetrics.shadowCardDark : AppMetrics.shadowCard,
      ),
      child: child,
    );
    return Material(
      color: cardColor,
      child: onTap == null
          ? card
          : InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: onTap,
              child: card,
            ),
    );
  }
}
