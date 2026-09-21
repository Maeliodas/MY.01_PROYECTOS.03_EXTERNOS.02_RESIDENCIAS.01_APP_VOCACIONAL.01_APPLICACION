import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/result_provider.dart';

class CareerRankingPage extends ConsumerWidget {
  const CareerRankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestResultProvider);
    ref.watch(careersCatalogProvider).valueOrNull ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error al cargar las carreras.')),
        data: (result) {
          if (result == null) {
            return const Center(child: Text('Completa el test para ver tus opciones.'));
          }
          final topThree = result.topThree;
          return ListView(
            padding: EdgeInsets.fromLTRB(22, 8, 22, 24 + MediaQuery.viewPaddingOf(context).bottom),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF0E3FF), borderRadius: BorderRadius.circular(12)),
                child: const Text('TOP 3 VOCACIONAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6C2BC8))),
              ),
              const SizedBox(height: 12),
              const Text('Tus 3 mejores\nopciones', style: TextStyle(fontSize: 34, height: 1.0, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(
                'Estas son las tres carreras con mayor afinidad respecto a tu perfil RIASEC. Puedes revisar el detalle de cada una.',
                style: TextStyle(fontSize: 15, height: 1.45, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68)),
              ),
              const SizedBox(height: 24),
              ...List.generate(topThree.length, (i) {
                final career = topThree[i];
                final top = i == 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: top ? AppColors.primary : const Color(0xFFE5ECD9), width: top ? 2 : 1),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .045), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i == 0 ? '1.er lugar' : '${i + 1}.º lugar',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: top ? const Color(0xFF00923F) : const Color(0xFF66746A)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(career.name, style: TextStyle(fontSize: top ? 20 : 18, height: 1.15, fontWeight: FontWeight.w900))),
                          const SizedBox(width: 12),
                          Text('${career.affinityPercentage.round()}%', style: TextStyle(fontSize: top ? 24 : 20, fontWeight: FontWeight.w900, color: top ? AppColors.primaryDark : const Color(0xFF18A9D3))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: career.affinityPercentage / 100,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFE4EBDD),
                          valueColor: AlwaysStoppedAnimation(top ? AppColors.primary : const Color(0xFF18A9D3)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/result-detail?career=${career.careerId}'),
                          child: const Text('Ver detalles →', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              const _TecContactCard(),
            ],
          );
        },
      ),
    );
  }
}


class _TecContactCard extends StatelessWidget {
  const _TecContactCard();

  Future<void> _open(String value) async {
    final uri = Uri.parse(value);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFDCE8D7)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .045), blurRadius: 16, offset: const Offset(0, 7))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .11), borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 27),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Da el siguiente paso', style: TextStyle(fontSize: 20, height: 1.1, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('Instituto Tecnológico de Tuxtepec', style: TextStyle(fontSize: 12.5, height: 1.25, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      ]),
      const SizedBox(height: 12),
      Text(
        'Conoce más sobre el Tec, su oferta académica y los medios oficiales para resolver tus dudas.',
        style: TextStyle(fontSize: 13.5, height: 1.42, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: () => _open('https://www.tuxtepec.tecnm.mx/'),
          icon: const Icon(Icons.public_rounded, size: 21),
          label: const Text('Ir al sitio oficial', style: TextStyle(fontWeight: FontWeight.w900)),
          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor.withValues(alpha: .65))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('REDES Y CONTACTO', style: TextStyle(fontSize: 10, letterSpacing: .75, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurfaceVariant))),
        Expanded(child: Divider(color: Theme.of(context).dividerColor.withValues(alpha: .65))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _ContactTile(label: 'Facebook', icon: const _FacebookIcon(), onTap: () => _open('https://www.facebook.com/tecnologicode.tuxtepec/'))),
        const SizedBox(width: 10),
        Expanded(child: _ContactTile(label: 'Instagram', icon: const _InstagramIcon(), onTap: () => _open('https://www.instagram.com/tecnm_tuxtepec/'))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _ContactTile(label: 'WhatsApp', icon: const _WhatsAppIcon(), onTap: () => _open('https://wa.me/522871104437'))),
        const SizedBox(width: 10),
        Expanded(child: _ContactTile(label: 'Correo', icon: const _MailIcon(), onTap: () => _open('mailto:web_tuxtepec@tecnm.mx'))),
      ]),
    ]),
  );
}

class _ContactTile extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  const _ContactTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              SizedBox(width: 34, height: 34, child: icon),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();
  @override Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Color(0xFF1877F2), shape: BoxShape.circle),
    alignment: Alignment.bottomCenter,
    child: const Text('f', style: TextStyle(color: Colors.white, fontSize: 29, height: 1.18, fontWeight: FontWeight.w900, fontFamily: 'Arial')),
  );
}

class _InstagramIcon extends StatelessWidget {
  const _InstagramIcon();
  @override Widget build(BuildContext context) => CustomPaint(painter: _InstagramPainter());
}

class _InstagramPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = const LinearGradient(
      begin: Alignment.bottomLeft, end: Alignment.topRight,
      colors: [Color(0xFFFFC107), Color(0xFFF44336), Color(0xFFE1306C), Color(0xFF833AB4), Color(0xFF405DE6)],
    ).createShader(rect);
    final bg = Paint()..shader = shader;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(size.width * .28)), bg);
    final line = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = size.width * .075;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(size.width * .20), Radius.circular(size.width * .18)), line);
    canvas.drawCircle(Offset(size.width * .5, size.height * .52), size.width * .145, line);
    canvas.drawCircle(Offset(size.width * .72, size.height * .29), size.width * .045, Paint()..color = Colors.white);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();
  @override Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
    child: Stack(alignment: Alignment.center, children: [
      const Icon(Icons.phone_rounded, color: Colors.white, size: 19),
      Positioned(
        left: 3,
        bottom: 2,
        child: Transform.rotate(
          angle: -.35,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFF25D366),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(2),
              ),
            ),
          ),
        ),
      ),
    ]),
  );
}

class _MailIcon extends StatelessWidget {
  const _MailIcon();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: dark
            ? colors.onSurface.withValues(alpha: .10)
            : const Color(0xFF1B396A).withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.mail_rounded,
        color: dark ? colors.onSurface : const Color(0xFF1B396A),
        size: 22,
      ),
    );
  }
}
