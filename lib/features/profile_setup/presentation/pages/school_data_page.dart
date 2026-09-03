import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../../avatar/presentation/providers/avatar_provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class SchoolDataPage extends ConsumerStatefulWidget {
  const SchoolDataPage({super.key});

  @override
  ConsumerState<SchoolDataPage> createState() => _SchoolDataPageState();
}

class _SchoolDataPageState extends ConsumerState<SchoolDataPage> {
  String? _selectedSchool;
  bool _speaksLanguages = false;
  final List<String> _selectedLanguages = [];
  final _customLanguageController = TextEditingController();
  bool _showCustomLanguageInput = false;

  // TODO: Reemplazar estas listas locales cuando conectes la base de datos local
  final List<String> _schoolsFromDb = [
    'CBTis 107',
    'COBAO 07',
    'CONALEP 157',
    'CBTA 51',
    'Preparatoria SIMÓN BOLÍVAR',
  ];

  final List<String> _languagesFromDb = [
    'Chinanteco',
    'Mazateco',
    'Zapoteco',
    'Mixe',
    'Inglés',
  ];

  @override
  void dispose() {
    _customLanguageController.dispose();
    super.dispose();
  }

  void _addCustomLanguage() {
    final text = _customLanguageController.text.trim();
    if (text.isNotEmpty && !_selectedLanguages.contains(text)) {
      setState(() {
        _selectedLanguages.add(text);
        _customLanguageController.clear();
        _showCustomLanguageInput = false;
      });
    }
  }

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
              // 1. Selección de Escuela utilizando initialValue
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedSchool),
                initialValue: _selectedSchool,
                decoration: const InputDecoration(
                  labelText: 'Escuela de procedencia',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Selecciona tu escuela'),
                items: _schoolsFromDb.map((school) {
                  return DropdownMenuItem<String>(
                    value: school,
                    child: Text(school),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSchool = val),
              ),
              const SizedBox(height: 24),

              // 2. Pregunta de Lenguas
              SwitchListTile(
                title:
                    const Text('¿Hablas alguna lengua materna o extranjera?'),
                value: _speaksLanguages,
                onChanged: (val) {
                  setState(() {
                    _speaksLanguages = val;
                    if (!val) {
                      _selectedLanguages.clear();
                      _showCustomLanguageInput = false;
                    }
                  });
                },
              ),

              // 3. Opciones de Lenguas desde BD + Opción Manual
              if (_speaksLanguages) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._languagesFromDb.map((lang) {
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
                    }),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Otra...'),
                      onPressed: () {
                        setState(() {
                          _showCustomLanguageInput = !_showCustomLanguageInput;
                        });
                      },
                    ),
                  ],
                ),
                if (_showCustomLanguageInput) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customLanguageController,
                          decoration: const InputDecoration(
                            labelText: 'Escribe la lengua',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addCustomLanguage,
                        icon: const Icon(Icons.check),
                      ),
                    ],
                  ),
                ],
                if (_selectedLanguages
                    .any((lang) => !_languagesFromDb.contains(lang))) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Agregadas manualmente:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _selectedLanguages
                        .where((lang) => !_languagesFromDb.contains(lang))
                        .map((lang) => Chip(
                              label: Text(lang),
                              onDeleted: () {
                                setState(() {
                                  _selectedLanguages.remove(lang);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
              ],

              const SizedBox(height: 32),

              // 4. Guardado final
              PrimaryButton(
                text: 'Guardar y Comenzar Test',
                onPressed: () async {
                  final avatarConfig = ref.read(avatarProvider);
                  final userProfile = UserProfile(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: extraData['name'] ?? 'Aspirante',
                    age: extraData['age'] ?? 18,
                    gender: extraData['gender'] ?? 'Otro',
                    school: _selectedSchool ?? 'No especificada',
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
