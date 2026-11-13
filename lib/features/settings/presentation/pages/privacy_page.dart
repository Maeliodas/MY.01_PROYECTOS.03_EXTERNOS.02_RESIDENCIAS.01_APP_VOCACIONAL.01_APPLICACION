import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_notice_dialog.dart';
import '../../../../core/widgets/institutional_logos.dart';

Widget _privacyContent(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final bodyColor =
      dark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${AppConstants.appName} · Aviso de privacidad del prototipo',
        style: AppTypography.headline.copyWith(
            color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary),
      ),
      const SizedBox(height: 10),
      Text(
        '${AppConstants.appName} utiliza únicamente la información necesaria para registrar tu perfil, aplicar el test vocacional, conservar tus resultados y sincronizarlos con el servidor institucional cuando está disponible.',
        style: AppTypography.body.copyWith(color: bodyColor),
      ),
      const SizedBox(height: 16),
      const _Section(
        'Datos utilizados',
        'Nombre, edad, género, estado, municipio, escuela de procedencia, lenguas o idiomas seleccionados, respuestas del test, resultado RIASEC, carrera recomendada y respuestas complementarias.',
      ),
      const _Section(
        'Finalidad',
        'Los datos se utilizan para ofrecer orientación vocacional, conservar el historial del estudiante y generar estadísticas académicas dentro del proyecto.',
      ),
      const _Section(
        'Almacenamiento y sincronización',
        'La app mantiene una copia local para funcionar sin conexión. Cuando el servidor institucional está configurado y disponible, las evaluaciones y catálogos se sincronizan mediante la API de ${AppConstants.appName}.',
      ),
      const _Section(
        'Seguridad',
        'La comunicación con el servidor debe realizarse mediante HTTPS/TLS en producción y el acceso administrativo al panel debe mantenerse protegido.',
      ),
      const _Section(
        'Derechos sobre tus datos',
        'Para solicitudes de acceso, rectificación, cancelación u oposición deberán utilizarse los mecanismos institucionales que correspondan al aviso de privacidad vigente del TecNM.',
      ),
      const SizedBox(height: 4),
      Text(
        'Este texto adapta el contenido al funcionamiento de ${AppConstants.appName} y no sustituye el Aviso de Privacidad Integral vigente del Tecnológico Nacional de México.',
        style: AppTypography.caption.copyWith(color: bodyColor),
      ),
    ],
  );
}

Future<void> showPrivacyNoticeDialog(BuildContext context) {
  return showAppNoticeDialog(
    context,
    icon: Icons.privacy_tip_outlined,
    title: 'Aviso de privacidad',
    content: _privacyContent(context),
    buttonText: 'Cerrar',
  );
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Aviso de privacidad')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          children: [
            _privacyContent(context),
            const SizedBox(height: 44),
            const InstitutionalFooter(showNames: false, scale: .9),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.title.copyWith(
                color:
                    dark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTypography.body.copyWith(
                color: dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
