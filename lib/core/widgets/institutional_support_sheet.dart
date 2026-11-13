import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_metrics.dart';
import '../../app/theme/app_typography.dart';
import '../constants/app_constants.dart';

/// Burbuja flotante de ayuda e información institucional (mapa vocacional).
///
/// Abre la hoja con los canales oficiales del TecNM Tuxtepec para que el
/// estudiante pueda pedir apoyo o ampliar información.
class InstitutionalSupportBubble extends StatelessWidget {
  const InstitutionalSupportBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showInstitutionalSupportSheet(context),
        child: const SizedBox(
          width: 54,
          height: 54,
          child: Icon(
            Icons.support_agent_rounded,
            color: AppColors.onPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

/// Hoja inferior con los canales oficiales del instituto.
///
/// Los iconos de redes conservan los colores de su marca (excepción aprobada
/// a la paleta institucional solo para redes sociales).
Future<void> showInstitutionalSupportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: false,
    builder: (sheetContext) {
      final dark = Theme.of(sheetContext).brightness == Brightness.dark;
      final titleColor =
          dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
      final subtitleColor =
          dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

      Future<void> open(String value) async {
        final uri = Uri.parse(value);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      return SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 560),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.borderDark : AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
                      child: Image.asset(
                        'assets/institution/ITTUX.png',
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: AppMetrics.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ayuda y contacto',
                            style: AppTypography.headline.copyWith(
                              fontSize: 19,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Canales oficiales del TecNM Tuxtepec',
                            style: AppTypography.caption.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SupportTile(
                  icon: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: dark
                          ? AppColors.primaryOnDarkContainer
                          : AppColors.blue50,
                      borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: AppColors.primary,
                      size: 23,
                    ),
                  ),
                  title: 'Sitio oficial',
                  subtitle: 'www.tuxtepec.tecnm.mx',
                  onTap: () => open(AppConstants.institutionSiteUrl),
                ),
                _SupportTile(
                  icon: const _BrandCircle(
                    color: Color(0xFF1877F2),
                    child: Text(
                      'f',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: 'Facebook',
                  subtitle: 'tecnologicode.tuxtepec',
                  onTap: () => open(AppConstants.institutionFacebookUrl),
                ),
                _SupportTile(
                  icon: const _InstagramBadge(),
                  title: 'Instagram',
                  subtitle: 'tecnm_tuxtepec',
                  onTap: () => open(AppConstants.institutionInstagramUrl),
                ),
                _SupportTile(
                  icon: const _BrandCircle(
                    color: Color(0xFF25D366),
                    child: Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  title: 'WhatsApp',
                  subtitle: '287 110 4437',
                  onTap: () => open(AppConstants.institutionWhatsAppUrl),
                ),
                _SupportTile(
                  icon: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: dark
                          ? AppColors.primaryOnDarkContainer
                          : AppColors.blue50,
                      borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
                    ),
                    child: const Icon(
                      Icons.mail_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: 'Correo institucional',
                  subtitle: 'web_tuxtepec@tecnm.mx',
                  onTap: () => open(AppConstants.institutionMailUrl),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SupportTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: dark ? AppColors.surfaceVariantDark : AppColors.blue50,
        borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyStrong.copyWith(
                          color: dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: dark ? AppColors.textSecondaryDark : AppColors.gray500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Círculo con color de marca (Facebook, WhatsApp).
class _BrandCircle extends StatelessWidget {
  final Color color;
  final Widget child;

  const _BrandCircle({required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: child,
      );
}

/// Insignia de Instagram con su gradiente oficial.
class _InstagramBadge extends StatelessWidget {
  const _InstagramBadge();

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(44, 44),
        painter: _InstagramGradientPainter(),
      );
}

class _InstagramGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFFFFC107),
          Color(0xFFF44336),
          Color(0xFFE1306C),
          Color(0xFF833AB4),
          Color(0xFF405DE6),
        ],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(1),
        Radius.circular(size.width * .28),
      ),
      bg,
    );
    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .075;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(size.width * .20),
        Radius.circular(size.width * .18),
      ),
      line,
    );
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .52),
      size.width * .145,
      line,
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .29),
      size.width * .045,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
