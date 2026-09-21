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
  final customLanguageNames = <String, String>{};
  final _customLanguageController = TextEditingController();
  final _customIdiomController = TextEditingController();
  final _customSchoolController = TextEditingController();
  bool _schoolNotListed = false;
  bool _sendingSuggestion = false;

  @override
  void dispose() {
    _customLanguageController.dispose();
    _customIdiomController.dispose();
    _customSchoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    final statesAsync = ref.watch(statesProvider);
    final municipalitiesAsync = stateId == null
        ? const AsyncData<List<Municipality>>([])
        : ref.watch(municipalitiesProvider(stateId!));
    final schoolsAsync = municipalityId == null
        ? const AsyncData<List<School>>([])
        : ref.watch(schoolsByMunicipalityProvider(municipalityId));
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
              'Selecciona tu estado, municipio y escuela de procedencia. Los catálogos se guardan en el dispositivo y se actualizan desde el servidor institucional cuando hay conexión.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),
            statesAsync.when(
              data: (states) => DropdownButtonFormField<String>(
                isExpanded: true,
                key: ValueKey('state-$stateId'),
                initialValue: states.any((item) => item.id == stateId) ? stateId : null,
                decoration: const InputDecoration(
                  labelText: 'Estado de procedencia',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: states
                    .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis)))
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
                isExpanded: true,
                key: ValueKey('municipality-$stateId-$municipalityId'),
                initialValue: items.any((item) => item.id == municipalityId) ? municipalityId : null,
                decoration: const InputDecoration(
                  labelText: 'Municipio',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: items
                    .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis)))
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
                isExpanded: true,
                key: ValueKey('school-$municipalityId-$schoolId'),
                initialValue: schools.any((item) => item.id == schoolId) ? schoolId : null,
                decoration: const InputDecoration(
                  labelText: 'Escuela de procedencia',
                  prefixIcon: Icon(Icons.school_outlined),
                  helperText: 'Las escuelas cambian según el municipio seleccionado.',
                ),
                items: schools
                    .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: municipalityId == null ? null : (value) => setState(() => schoolId = value),
              ),
              loading: () => const _LoadingField(label: 'Cargando escuelas…'),
              error: (_, __) => const _ErrorField(label: 'No se pudieron cargar las escuelas'),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('No encuentro mi escuela'),
              subtitle: const Text('Puedes proponerla para que un administrador la revise.'),
              value: _schoolNotListed,
              onChanged: municipalityId == null ? null : (value) => setState(() {
                _schoolNotListed = value ?? false;
                if (_schoolNotListed) schoolId = null;
              }),
            ),
            if (_schoolNotListed)
              TextField(
                controller: _customSchoolController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la escuela',
                  prefixIcon: Icon(Icons.add_business_outlined),
                  helperText: 'La sugerencia quedará asociada al municipio seleccionado.',
                ),
                onChanged: (_) => setState(() {}),
              ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: SwitchListTile.adaptive(
                title: const Text(
                  '¿Hablas alguna lengua originaria o algún idioma adicional?',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                value: speaksLanguages,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() {
                  speaksLanguages = value;
                  if (!value) {
                    selectedLanguageIds.clear();
                    selectedLanguageNames.clear();
                    customLanguageNames.clear();
                  }
                }),
              ),
            ),
            if (speaksLanguages) ...[
              const SizedBox(height: 18),
              const Text('Lenguas originarias', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              languagesAsync.when(
                data: (items) => _buildLanguageChips(
                  items.where((item) => item.type == 'lengua').toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('No fue posible cargar el catálogo de lenguas.'),
              ),
              const SizedBox(height: 12),
              _CustomCatalogInput(
                controller: _customLanguageController,
                label: '¿No aparece tu lengua? Escríbela aquí',
                icon: Icons.record_voice_over_outlined,
                enabled: !_sendingSuggestion,
                onAdd: () => _addCustom(kind: 'lengua', controller: _customLanguageController),
              ),
              if (customLanguageNames.entries.any((e) => e.key.startsWith('lengua_'))) ...[
                const SizedBox(height: 8),
                _customChips('lengua'),
              ],
              const SizedBox(height: 22),
              const Text('Idiomas', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              languagesAsync.when(
                data: (items) => _buildLanguageChips(
                  items.where((item) => item.type == 'idioma').toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('No fue posible cargar el catálogo de idiomas.'),
              ),
              const SizedBox(height: 12),
              _CustomCatalogInput(
                controller: _customIdiomController,
                label: '¿No aparece tu idioma? Escríbelo aquí',
                icon: Icons.translate_rounded,
                enabled: !_sendingSuggestion,
                onAdd: () => _addCustom(kind: 'idioma', controller: _customIdiomController),
              ),
              if (customLanguageNames.entries.any((e) => e.key.startsWith('idioma_'))) ...[
                const SizedBox(height: 8),
                _customChips('idioma'),
              ],
              const SizedBox(height: 8),
              Text(
                'Los nombres escritos se guardan para tu perfil y se envían como sugerencia al panel. Un administrador puede aprobarlos para que aparezcan en el catálogo de todos los dispositivos.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 34),
            PrimaryButton(
              text: 'Guardar y comenzar test',
              icon: Icons.arrow_forward_rounded,
              onPressed: stateId == null || municipalityId == null || (!_schoolNotListed && schoolId == null) || (_schoolNotListed && _customSchoolController.text.trim().length < 2)
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

  Widget _customChips(String kind) {
    final entries = customLanguageNames.entries.where((e) => e.key.startsWith('${kind}_')).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((entry) => InputChip(
        label: Text(entry.value),
        selected: true,
        onDeleted: () => setState(() {
          customLanguageNames.remove(entry.key);
          selectedLanguageIds.remove(entry.key);
          selectedLanguageNames.remove(entry.value);
        }),
      )).toList(),
    );
  }

  Future<void> _addCustom({
    required String kind,
    required TextEditingController controller,
  }) async {
    final name = _sentenceCase(controller.text);
    if (name.length < 2) return;

    final normalized = name.toLowerCase();
    if (selectedLanguageNames.any((item) => item.toLowerCase() == normalized)) {
      controller.clear();
      return;
    }

    final id = '${kind}_custom_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      selectedLanguageIds.add(id);
      selectedLanguageNames.add(name);
      customLanguageNames[id] = name;
      _sendingSuggestion = true;
    });
    controller.clear();

    final sent = await ref.read(catalogSyncServiceProvider).suggest(kind: kind, name: name);
    if (!mounted) return;
    setState(() => _sendingSuggestion = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Sugerencia enviada al panel para revisión.'
              : 'Se guardó en tu perfil. La sugerencia se enviará cuando el servidor esté disponible.',
        ),
      ),
    );
  }

  Future<void> _saveProfile(Map<String, dynamic> extra) async {
    final states = await ref.read(statesProvider.future);
    final municipalities = await ref.read(municipalitiesProvider(stateId!).future);
    final schools = await ref.read(schoolsByMunicipalityProvider(municipalityId).future);
    final state = states.firstWhere((item) => item.id == stateId);
    final municipality = municipalities.firstWhere((item) => item.id == municipalityId);
    final selectedSchool = schoolId == null ? null : schools.firstWhere((item) => item.id == schoolId);

    int? pendingSchoolSuggestionId;
    String? pendingSchoolName;
    if (_schoolNotListed) {
      pendingSchoolName = _sentenceCase(_customSchoolController.text);
      pendingSchoolSuggestionId = await ref.read(catalogSyncServiceProvider).suggestSchool(
        name: pendingSchoolName,
        municipalityId: municipalityId!,
      );
      if (pendingSchoolSuggestionId == null) return;
    }

    final ids = selectedLanguageIds.toList();
    final catalog = await ref.read(allLanguagesProvider.future);
    final catalogById = {for (final item in catalog) item.id: item.name};
    final names = ids
        .map((id) => catalogById[id] ?? customLanguageNames[id] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final profile = UserProfile(
      id: '1',
      name: extra['name']?.toString() ?? 'Aspirante',
      age: (extra['age'] as num?)?.toInt() ?? 18,
      gender: extra['gender']?.toString() ?? 'Otro',
      stateId: stateId,
      state: state.name,
      municipalityId: municipalityId,
      municipality: municipality.name,
      schoolId: _schoolNotListed ? null : schoolId,
      pendingSchoolSuggestionId: pendingSchoolSuggestionId,
      school: pendingSchoolName ?? selectedSchool?.name ?? 'No especificada',
      pendingSchoolName: pendingSchoolName,
      speaksLanguages: speaksLanguages,
      languageIds: ids,
      languagesList: names,
      avatarConfig: ref.read(avatarProvider),
      createdAt: DateTime.now(),
    );
    await ref.read(profileProvider.notifier).saveProfile(profile);
    if (mounted) context.go('/path-home');
  }
}

String _sentenceCase(String value) {
  final clean = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (clean.isEmpty) return '';
  final lower = clean.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

class _CustomCatalogInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onAdd;

  const _CustomCatalogInput({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Agregar y sugerir',
            onPressed: enabled ? onAdd : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      );
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
