import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../../avatar/presentation/providers/avatar_provider.dart';
import '../../profile/domain/entities/user_profile.dart';
import '../../profile/presentation/providers/profile_provider.dart';

class SchoolDataPage extends ConsumerStatefulWidget {
  const SchoolDataPage({super.key});

  @override
  ConsumerState<SchoolDataPage> createState() => _SchoolDataPageState();
}

class _SchoolDataPageState extends ConsumerState<SchoolDataPage> {
  final _schoolController = TextEditingController();
  bool _speaksLanguages = false;
  final List<String> _selectedLanguages = [];

  final List<String> _predefinedLanguages = [
    'Chinanteco',
    'Mazateco',
    'Zapoteco',
    'Mixe',
    'Inglés',
  ];

  @override
  Widget build(BuildContext context) {
    final extraData =
        GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Datos Escolares')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(
                  labelText: 'Escuela de procedencia',
                  border: OutlineInputBorder(),
                  hintText: 'Ej. CBTis 107, COBAO 07',
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title:
                    const Text('¿Hablas alguna lengua materna o extranjera?'),
                value: _speaksLanguages,
                onChanged: (val) => setState(() => _speaksLanguages = val),
              ),
              if (_speaksLanguages) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _predefinedLanguages.map((lang) {
                    final isSelected = _selectedLanguages.contains(lang);
                    return FilterChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedLanguages.add(lang);
                          } else {
                            _selectedLanguages.remove(lang);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Guardar y Comenzar Test',
                onPressed: () async {
                  final avatarConfig = ref.read(avatarProvider);
                  final userProfile = UserProfile(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: extraData['name'] ?? 'Aspirante',
                    age: extraData['age'] ?? 18,
                    gender: extraData['gender'] ?? 'Otro',
                    school: _schoolController.text.trim().isEmpty
                        ? 'No especificada'
                        : _schoolController.text.trim(),
                    speaksLanguages: _speaksLanguages,
                    languagesList: _selectedLanguages,
                    avatarConfig: avatarConfig,
                    createdAt: DateTime.now(),
                  );

                  await ref
                      .read(profileProvider.notifier)
                      .saveProfile(userProfile);
                  if (context.mounted) {
                    context.go('/test-intro');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
