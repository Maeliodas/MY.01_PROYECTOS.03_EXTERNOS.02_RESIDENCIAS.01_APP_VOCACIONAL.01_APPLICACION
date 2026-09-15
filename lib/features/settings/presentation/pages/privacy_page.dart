import 'package:flutter/material.dart';

import '../../../../core/widgets/app_notice_dialog.dart';

Widget _privacyContent(BuildContext context) {
  final muted = Theme.of(context).colorScheme.onSurfaceVariant;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'App Vocacional ITTUX  · Aviso de privacidad del prototipo',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 10),
      Text(
        'App Vocacional ITTUX  utiliza únicamente la información necesaria para registrar tu perfil, aplicar el test vocacional, conservar tus resultados y sincronizarlos con el servidor institucional cuando está disponible.',
        style: TextStyle(color: muted),
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
        'La app mantiene una copia local para funcionar sin conexión. Cuando el servidor institucional está configurado y disponible, las evaluaciones y catálogos se sincronizan mediante la API de App Vocacional ITTUX .',
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
        'Este texto adapta el contenido al funcionamiento de App Vocacional ITTUX  y no sustituye el Aviso de Privacidad Integral vigente del Tecnológico Nacional de México.',
        style: TextStyle(fontSize: 12, color: muted),
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
          children: [_privacyContent(context)],
        ),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(body),
          ],
        ),
      );
}
