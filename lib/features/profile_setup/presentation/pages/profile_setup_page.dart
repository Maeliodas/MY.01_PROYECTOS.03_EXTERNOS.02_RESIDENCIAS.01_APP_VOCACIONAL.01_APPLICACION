import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../data/profile_repository.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});
  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  String? schoolId;
  bool mother = false;
  bool foreign = false;
  final motherIds = <String>{};
  final foreignIds = <String>{};
  final customMother = <String>[];
  final customForeign = <String>[];

  Future<void> _save() async {
    await ProfileRepository().saveLanguages(
      schoolId: schoolId,
      speaksMother: mother,
      motherIds: motherIds.toList(),
      customMother: customMother,
      speaksForeign: foreign,
      foreignIds: foreignIds.toList(),
      customForeign: customForeign,
    );
    if (mounted) context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final schools = ref.watch(schoolsProvider);
    final mothers = ref.watch(motherLanguagesProvider);
    final foreigners = ref.watch(foreignLanguagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tu información')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          schools.when(
            data: (items) => DropdownButtonFormField<String>(
              value: schoolId,
              decoration: const InputDecoration(labelText: 'Escuela de procedencia'),
              items: items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
              onChanged: (v) => setState(() => schoolId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('No fue posible cargar escuelas'),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            value: mother,
            title: const Text('¿Hablas alguna lengua materna?'),
            onChanged: (v) => setState(() => mother = v),
          ),
          if (mother) mothers.when(
            data: (items) => _LanguageMultiSelector(
              languages: items,
              selected: motherIds,
              onChanged: (values) => setState(() { motherIds..clear()..addAll(values); }),
              custom: customMother,
              onCustomChanged: (values) => setState(() { customMother..clear()..addAll(values); }),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: foreign,
            title: const Text('¿Hablas alguna lengua extranjera?'),
            onChanged: (v) => setState(() => foreign = v),
          ),
          if (foreign) foreigners.when(
            data: (items) => _LanguageMultiSelector(
              languages: items,
              selected: foreignIds,
              onChanged: (values) => setState(() { foreignIds..clear()..addAll(values); }),
              custom: customForeign,
              onCustomChanged: (values) => setState(() { customForeign..clear()..addAll(values); }),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: schoolId == null ? null : _save, child: const Text('Guardar y continuar')),
        ],
      ),
    );
  }
}

class _LanguageMultiSelector extends StatelessWidget {
  final List<Language> languages;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final List<String> custom;
  final ValueChanged<List<String>> onCustomChanged;
  const _LanguageMultiSelector({required this.languages, required this.selected, required this.onChanged, required this.custom, required this.onCustomChanged});

  @override
  Widget build(BuildContext context) => Card(
    child: Column(children: [
      ...languages.map((l) => CheckboxListTile(
        value: selected.contains(l.id),
        title: Text(l.name),
        onChanged: (v) {
          final next = {...selected};
          v == true ? next.add(l.id) : next.remove(l.id);
          onChanged(next);
        },
      )),
      ListTile(
        leading: const Icon(Icons.add_circle_outline),
        title: const Text('Otra lengua'),
        onTap: () async {
          final controller = TextEditingController();
          final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Especifica la lengua'),
            content: TextField(controller: controller, autofocus: true),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Agregar'))],
          ));
          if (value != null && value.isNotEmpty) onCustomChanged([...custom, value]);
        },
      ),
      ...custom.map((name) => ListTile(
        title: Text(name),
        trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => onCustomChanged(custom.where((e) => e != name).toList())),
      )),
    ]),
  );
}
