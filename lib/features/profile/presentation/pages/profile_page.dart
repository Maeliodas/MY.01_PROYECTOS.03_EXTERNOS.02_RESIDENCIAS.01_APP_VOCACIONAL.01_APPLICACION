import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final p = r.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: p.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (x) => x == null
            ? const Center(child: Text('Perfil no disponible'))
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(child: AvatarCircle(id: x.avatarId, radius: 45)),
                  const SizedBox(height: 16),
                  Text(x.name, style: Theme.of(c).textTheme.headlineSmall),
                  Text('Edad: ${x.age ?? 'No especificada'}'),
                  Text('Género: ${x.gender ?? 'No especificado'}'),
                  Text('Escuela: ${x.schoolNameSnapshot ?? 'No especificada'}'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => c.push('/profile/edit'),
                    child: const Text('Editar perfil'),
                  ),
                ],
              ),
      ),
    );
  }
}
