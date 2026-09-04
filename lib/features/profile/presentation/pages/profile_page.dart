import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aevum Iter'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: CircleAvatar(
                      radius: 46,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accentPurple,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.share, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Alex Rivera', style: AppTextStyles.titleLarge),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '🏅 Nivel: Explorador',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.check_circle_outline,
                            color: AppColors.primary, size: 28),
                        SizedBox(height: 6),
                        Text('TESTS COMPLETADOS', style: AppTextStyles.caption),
                        SizedBox(height: 4),
                        Text('1', style: AppTextStyles.titleLarge),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.star,
                            color: AppColors.accentPurple, size: 28),
                        SizedBox(height: 6),
                        Text('RACHA ACTUAL', style: AppTextStyles.caption),
                        SizedBox(height: 4),
                        Text('3 Días',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentPurple)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Progreso de Carrera',
                          style: AppTextStyles.titleMedium),
                      Text('75%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.75,
                    color: Colors.lightBlue,
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        TextSpan(
                            text:
                                '¡Vas por buen camino! Estás a un paso de desbloquear tu perfil de '),
                        TextSpan(
                          text: 'Ingeniería en Sistemas.',
                          style: TextStyle(
                              color: AppTextStyles.textBlueMatch,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: const CircleAvatar(
                backgroundColor: AppColors.lightPurpleMatch,
                child: Icon(Icons.military_tech, color: AppColors.accentPurple),
              ),
              title: const Text('Mis Logros'),
              subtitle: const Text('4 insignias ganadas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: const CircleAvatar(
                backgroundColor: AppColors.lightBlueMatch,
                child: Icon(Icons.history, color: AppColors.accentBlue),
              ),
              title: const Text('Historial'),
              subtitle: const Text('Revisa tus resultados previos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoutBg,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.logout, color: AppColors.destructiveRed),
              label: const Text('Cerrar Sesión',
                  style: TextStyle(
                      color: AppColors.destructiveRed,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/career-ranking');
        },
        items: const [
          BottomNavigationBarThemeData().items?[0] ??
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'PATH'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'LOGROS'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PERFIL'),
        ],
      ),
    );
  }
}
