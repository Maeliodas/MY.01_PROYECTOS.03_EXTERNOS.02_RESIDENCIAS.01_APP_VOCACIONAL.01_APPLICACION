import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../avatar/presentation/providers/avatar_provider.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class SchoolDataPage extends ConsumerStatefulWidget {
  const SchoolDataPage({super.key});

  @override
  ConsumerState<SchoolDataPage> createState() => _SchoolDataPageState();
}

class _SchoolDataPageState extends ConsumerState<SchoolDataPage> {
  String? stateId = '20';
  String? municipalityId;
  String? schoolId;
  bool speaksLanguages = false;
  final selectedLanguageIds = <String>{};
  final selectedLanguageNames = <String>{};

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    final statesAsync = ref.watch(statesProvider);
    final municipalitiesAsync = stateId == null
        ? const AsyncData<List<Municipality>>([])
        : ref.watch(municipalitiesProvider(stateId!));
    final schoolsAsync = ref.watch(
      schoolsByMunicipalityProvider(municipalityId),
    );
    final languagesAsync = ref.watch(allLanguagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Información académica')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          children: [
            const Text(
              'Un último dato',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona tu procedencia. Los catálogos se consultan desde la base de datos local.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),
            statesAsync.when(
              data: (states) => DropdownButtonFormField<String>(
                key: ValueKey('state-$stateId'),
                initialValue: states.any((item) => item.id == stateId) ? stateId : null,
                decoration: const InputDecoration(
                  labelText: 'Estado de procedencia',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: states
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    stateId = value;
                    municipalityId = null;
                    schoolId = null;
                  });
                },
              ),
              loading: () => const _LoadingField(label: 'Cargando estados…'),
              error: (_, __) => const _ErrorField(label: 'No se pudieron cargar los estados'),
            ),
            const SizedBox(height: 14),
            municipalitiesAsync.when(
              data: (items) => DropdownButtonFormField<String>(
                key: ValueKey('municipality-$stateId-$municipalityId'),
                initialValue: items.any((item) => item.id == municipalityId)
                    ? municipalityId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Municipio',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: stateId == null
                    ? null
                    : (value) {
                        setState(() {
                          municipalityId = value;
                          schoolId = null;
                        });
                      },
              ),
              loading: () => const _LoadingField(label: 'Cargando municipios…'),
              error: (_, __) => const _ErrorField(label: 'No se pudieron cargar los municipios'),
            ),
            const SizedBox(height: 14),
            schoolsAsync.when(
              data: (schools) => DropdownButtonFormField<String>(
                key: ValueKey('school-$municipalityId-$schoolId'),
                initialValue: schools.any((item) => item.id == schoolId) ? schoolId : null,
                decoration: const InputDecoration(
                  labelText: 'Escuela de procedencia',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: schools
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => schoolId = value),
              ),
              loading: () => const _LoadingField(label: 'Cargando escuelas…'),
              error: (_, __) => const _ErrorField(label: 'No se pudieron cargar las escuelas'),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: SwitchListTile.adaptive(
                title: const Text(
                  '¿Hablas alguna lengua materna o extranjera?',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                value: speaksLanguages,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() {
                  speaksLanguages = value;
                  if (!value) {
                    selectedLanguageIds.clear();
                    selectedLanguageNames.clear();
                  }
                }),
              ),
            ),
            if (speaksLanguages) ...[
              const SizedBox(height: 16),
              const Text('Lenguas e idiomas', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              languagesAsync.when(
                data: _buildLanguageChips,
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('No fue posible cargar el catálogo de lenguas e idiomas.'),
              ),
            ],
            const SizedBox(height: 34),
            PrimaryButton(
              text: 'Guardar y comenzar test',
              icon: Icons.arrow_forward_rounded,
              onPressed: stateId == null || municipalityId == null || schoolId == null
                  ? null
                  : () => _saveProfile(extra),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChips(List<Language> languages) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: languages.map((language) {
        final selected = selectedLanguageIds.contains(language.id);
        return FilterChip(
          label: Text(language.name),
          selected: selected,
          selectedColor: AppColors.primaryLight,
          onSelected: (value) => setState(() {
            if (value) {
              selectedLanguageIds.add(language.id);
              selectedLanguageNames.add(language.name);
            } else {
              selectedLanguageIds.remove(language.id);
              selectedLanguageNames.remove(language.name);
            }
          }),
        );
      }).toList(),
    );
  }

  Future<void> _saveProfile(Map<String, dynamic> extra) async {
    final states = await ref.read(statesProvider.future);
    final municipalities = await ref.read(municipalitiesProvider(stateId!).future);
    final schools = await ref.read(schoolsByMunicipalityProvider(municipalityId).future);

    final state = states.firstWhere((item) => item.id == stateId);
    final municipality = municipalities.firstWhere((item) => item.id == municipalityId);
    final school = schools.firstWhere((item) => item.id == schoolId);

    final profile = UserProfile(
      id: '1',
      name: extra['name']?.toString() ?? 'Aspirante',
      age: (extra['age'] as num?)?.toInt() ?? 18,
      gender: extra['gender']?.toString() ?? 'Otro',
      stateId: state.id,
      state: state.name,
      municipalityId: municipality.id,
      municipality: municipality.name,
      schoolId: school.id,
      school: school.name,
      speaksLanguages: speaksLanguages,
      languageIds: selectedLanguageIds.toList(),
      languagesList: selectedLanguageNames.toList(),
      avatarConfig: ref.read(avatarProvider),
      createdAt: DateTime.now(),
    );
    await ref.read(profileProvider.notifier).saveProfile(profile);
    if (mounted) context.go('/path-home');
  }
}

class _LoadingField extends StatelessWidget {
  final String label;
  const _LoadingField({required this.label});
  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: const LinearProgressIndicator(),
      );
}

class _ErrorField extends StatelessWidget {
  final String label;
  const _ErrorField({required this.label});
  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: const InputDecoration(errorText: 'Error de catálogo'),
        child: Text(label),
      );
}
