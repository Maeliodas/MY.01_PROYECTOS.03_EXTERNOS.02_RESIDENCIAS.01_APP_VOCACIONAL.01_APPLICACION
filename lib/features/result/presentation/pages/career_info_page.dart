import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

class CareerInfoPage extends ConsumerWidget {
  const CareerInfoPage({
    super.key,
    required this.careerId,
    required this.careerName,
    this.affinity,
    this.rank,
  });

  final String careerId;
  final String careerName;
  final double? affinity;
  final int? rank;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool _isRemoteUrl(String? path) {
    if (path == null || path.isEmpty) return false;
    final lower = path.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careersAsync = ref.watch(careersCatalogProvider);
    final contactsAsync = ref.watch(instituteContactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de carrera')),
      body: careersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => const Center(
          child: Text('No se pudo cargar la información de la carrera.'),
        ),
        data: (careers) {
          CareerCatalog? catalog;
          for (final c in careers) {
            if (c.id == careerId) {
              catalog = c;
              break;
            }
          }

          final name =
              catalog?.name.isNotEmpty == true ? catalog!.name : careerName;
          final description = (catalog?.description ?? '').trim().isEmpty
              ? 'Consulta con el instituto el plan de estudios, el perfil de egreso '
                  'y las oportunidades profesionales de esta carrera.'
              : catalog!.description;
          final shortDescription = catalog?.shortDescription.trim() ?? '';
          final holland = catalog?.hollandCode ?? '';
          final pdfPath = catalog?.pdfPath;
          final canOpenPdf = _isRemoteUrl(pdfPath);

          final contacts = contactsAsync.asData?.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
            children: [
              if (rank != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OPCIÓN #$rank',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6C2BC8),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (affinity != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Afinidad vocacional: ${affinity!.round()}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .7),
                  ),
                ),
              ],
              if (holland.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Código Holland: $holland',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C2BC8),
                  ),
                ),
              ],
              if (shortDescription.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  shortDescription,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .75),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5ECD9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información básica',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1C2C18)
                      : const Color(0xFFE9FADB),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.picture_as_pdf_rounded,
                            color: Color(0xFF287400)),
                        SizedBox(width: 8),
                        Text(
                          'Kardex / Plan de estudios',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      canOpenPdf
                          ? 'Abre el documento oficial de esta carrera.'
                          : 'Cuando el panel web publique el PDF (URL), podrás '
                              'abrirlo aquí. Por ahora consulta el sitio del instituto.',
                      style: TextStyle(
                        height: 1.4,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .72),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (canOpenPdf)
                      FilledButton.icon(
                        onPressed: () => _open(pdfPath!),
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('Abrir PDF'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => _open(
                          contacts?.webUrl ?? 'https://tuxtepec.tecnm.mx',
                        ),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Ver en sitio web del Tec'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF162831)
                      : const Color(0xFFE1F4FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contactar al instituto',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Resuelve dudas de admisión, planes de estudio o visitas.',
                      style: TextStyle(
                        height: 1.35,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ContactButton(
                      icon: Icons.language_rounded,
                      label: 'Sitio web oficial',
                      subtitle: contacts?.webUrl
                              .replaceFirst(RegExp(r'^https?://'), '') ??
                          'tuxtepec.tecnm.mx',
                      color: const Color(0xFF18A9D3),
                      onTap: () => _open(
                        contacts?.webUrl ?? 'https://tuxtepec.tecnm.mx',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ContactButton(
                      icon: Icons.facebook_rounded,
                      label: 'Facebook',
                      subtitle: 'TecNM Tuxtepec',
                      color: const Color(0xFF1877F2),
                      onTap: () => _open(
                        contacts?.facebookUrl ??
                            'https://www.facebook.com/TecNMTuxtepec',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ContactButton(
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      subtitle: contacts?.phoneDisplay ?? '(287) 875 1044',
                      color: const Color(0xFF25D366),
                      onTap: () => _open(
                        contacts?.whatsappUrl ?? 'https://wa.me/522878751044',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .85),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
