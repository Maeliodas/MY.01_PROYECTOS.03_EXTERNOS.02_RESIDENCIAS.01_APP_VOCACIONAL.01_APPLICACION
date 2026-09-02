import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});
  @override
  ConsumerState<EditProfilePage> createState() => _S();
}

class _S extends ConsumerState<EditProfilePage> {
  final name = TextEditingController();
  bool init = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final p = ref.watch(profileProvider);
    if (!init && p.hasValue && p.value != null) {
      name.text = p.value!.name;
      init = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: p.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('$e'),
        data: (x) => x == null
            ? const Text('Perfil no disponible')
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await ref
                              .read(profileRepositoryProvider)
                              .save(x.copyWith(name: name.text.trim()));
                          ref.invalidate(profileProvider);
                          if (c.mounted) c.go('/profile');
                        },
                        child: const Text('Guardar cambios'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
