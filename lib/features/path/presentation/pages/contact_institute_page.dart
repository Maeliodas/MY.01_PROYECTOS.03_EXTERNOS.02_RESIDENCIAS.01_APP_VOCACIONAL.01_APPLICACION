import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ContactInstitutePage extends StatelessWidget {
  const ContactInstitutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instituto TecNM Tuxtepec')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primaryGreenLight.withValues(alpha: 0.3),
              ),
              child: const Icon(Icons.school,
                  size: 80, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instituto Tecnológico de Tuxtepec',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Formando profesionistas líderes para el desarrollo tecnológico e industrial de la región.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(Icons.location_on, color: AppColors.primaryGreen),
              title: Text('Dirección'),
              subtitle:
                  Text('Av. Doctor Víctor Bravo Ahuja S/N, Tuxtepec, Oax.'),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: AppColors.primaryGreen),
              title: Text('Teléfono'),
              subtitle: Text('(287) 875 1044'),
            ),
            const ListTile(
              leading: Icon(Icons.language, color: AppColors.primaryGreen),
              title: Text('Sitio Web'),
              subtitle: Text('tuxtepec.tecnm.mx'),
            ),
          ],
        ),
      ),
    );
  }
}
