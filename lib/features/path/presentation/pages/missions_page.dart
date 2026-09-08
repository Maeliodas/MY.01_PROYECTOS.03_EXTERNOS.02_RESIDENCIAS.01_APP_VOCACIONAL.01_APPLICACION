import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Misiones Vocacionales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MissionCard(
            title: 'Explora tu Carrera #1',
            description:
                'Lee el plan de estudios completo de tu opción con mayor afinidad.',
            icon: Icons.menu_book,
            isDone: true,
          ),
          _MissionCard(
            title: 'Visita el Laboratorio',
            description:
                'Programa una visita guiada a los laboratorios del TecNM Tuxtepec.',
            icon: Icons.science,
            isDone: false,
          ),
          _MissionCard(
            title: 'Habla con un Tutor',
            description:
                'Agenda una sesión de orientación vocacional de 15 minutos.',
            icon: Icons.support_agent,
            isDone: false,
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isDone;

  const _MissionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor:
              isDone ? AppColors.primaryGreen : AppColors.textLightGrey,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: isDone
            ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
            : const Icon(Icons.circle_outlined, color: AppColors.textLightGrey),
      ),
    );
  }
}
