import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _stateController;
  // late TextEditingController _municipalityController;
  late TextEditingController _schoolController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile?.name ?? '');
    _stateController = TextEditingController(text: profile?.state ?? '');
    // _municipalityController = TextEditingController(text: profile?.municipality ?? '');
    _schoolController = TextEditingController(text: profile?.school ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: 'Estado de procedencia',
                border: OutlineInputBorder(),
              ),
            ),
            // TODOAtivar junto con el campo municipality en UserProfile.
            // const SizedBox(height: 16),
            // TextFormField(
            //   controller: _municipalityController,
            //   decoration: const InputDecoration(
            //     labelText: 'Localidad o municipio',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _schoolController,
              decoration: const InputDecoration(
                labelText: 'Escuela',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Guardar Cambios',
              onPressed: () async {
                final current = ref.read(profileProvider);
                if (current != null) {
                  final updated = UserProfile(
                    id: current.id,
                    name: _nameController.text,
                    age: current.age,
                    gender: current.gender,
                    state: _stateController.text.trim().isEmpty
                        ? current.state
                        : _stateController.text.trim(),
                    // municipality: _municipalityController.text.trim().isEmpty
                    //     ? current.municipality
                    //     : _municipalityController.text.trim(),
                    school: _schoolController.text,
                    speaksLanguages: current.speaksLanguages,
                    languagesList: current.languagesList,
                    avatarConfig: current.avatarConfig,
                    createdAt: current.createdAt,
                  );
                  await ref.read(profileProvider.notifier).saveProfile(updated);
                  if (context.mounted) context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
