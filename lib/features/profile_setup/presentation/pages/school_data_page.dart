import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/profile_setup_provider.dart';
import '../../../../core/widgets/primary_button.dart';

class SchoolDataPage extends ConsumerStatefulWidget {
  const SchoolDataPage({super.key});

  @override
  ConsumerState<SchoolDataPage> createState() => _S();
}

class _S extends ConsumerState<SchoolDataPage> {
  String? school;
  String? lang;

  final other = TextEditingController();

  bool speaks = false;

  @override
  void dispose() {
    other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final schools = ref.watch(catalogSchoolsProvider);
    final langs = ref.watch(catalogLanguagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Datos escolares')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          schools.when(
            data: (x) => DropdownButtonFormField<String>(
              initialValue: school,
              decoration: const InputDecoration(
                labelText: 'Escuela de procedencia',
              ),
              items: x
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e['id'],
                      child: Text(e['name']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                school = v;
              }),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) =>
                const Text('No se pudo cargar el catálogo de escuelas'),
          ),

          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('¿Hablas alguna lengua materna?'),
            value: speaks,
            onChanged: (v) => setState(() {
              speaks = v;

              if (!speaks) {
                lang = null;
                other.clear();
              }
            }),
          ),

          if (speaks)
            langs.when(
              data: (x) => Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: lang,
                    decoration: const InputDecoration(labelText: 'Lengua'),
                    items: x
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e['id'],
                            child: Text(e['name']!),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      lang = v;
                    }),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: other,
                    decoration: const InputDecoration(labelText: 'Otra lengua'),
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) =>
                  const Text('No se pudo cargar el catálogo de lenguas'),
            ),

          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Continuar',
            onPressed: () {
              final ss = ref.read(profileSetupProvider);

              final schoolData = (schools.asData?.value ?? [])
                  .where((e) => e['id'] == school)
                  .toList();

              final languageData = (langs.asData?.value ?? [])
                  .where((e) => e['id'] == lang)
                  .toList();

              ref.read(profileSetupProvider.notifier).state = ss.copyWith(
                schoolId: school,
                schoolName: schoolData.isEmpty
                    ? null
                    : schoolData.first['name'],
                languageIds: lang == null ? [] : [lang!],
                languageNames: languageData.isEmpty
                    ? []
                    : [languageData.first['name']!],
                otherLanguage: other.text.trim().isEmpty
                    ? null
                    : other.text.trim(),
              );

              context.push('/avatar');
            },
          ),
        ],
      ),
    );
  }
}
