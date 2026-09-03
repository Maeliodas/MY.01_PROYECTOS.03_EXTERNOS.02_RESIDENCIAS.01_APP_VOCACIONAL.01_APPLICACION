import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Cargando perfil...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AvatarCircle(
                    avatarPath: profile.avatarConfig.avatarPath,
                    radius: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile.school,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('Ver Historial de Tests'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/history'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Editar Perfil'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/edit-profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
