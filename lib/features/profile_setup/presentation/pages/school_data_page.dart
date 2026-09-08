import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
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
  String school = 'CBTis 107';
  String state = 'Oaxaca';
  bool speaksLanguages = false;
  final selectedLanguages = <String>{};
  final schools = const ['CBTis 107', 'COBAO 07', 'CONALEP 157', 'CBTA 51', 'Preparatoria SIMÓN BOLÍVAR', 'Otra'];
  final languages = const ['Chinanteco', 'Mazateco', 'Zapoteco', 'Mixe', 'Inglés'];

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('Información académica')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          children: [
            const Text('Un último dato', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Esto nos ayuda a contextualizar tu experiencia sin cambiar tu resultado RIASEC.', style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 26),
            DropdownButtonFormField<String>(initialValue: state, decoration: const InputDecoration(labelText: 'Estado de procedencia', prefixIcon: Icon(Icons.location_on_outlined)), items: ['Oaxaca', 'Veracruz', 'Puebla', 'Chiapas', 'Otro'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => state = v ?? state)),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(initialValue: school, decoration: const InputDecoration(labelText: 'Escuela de procedencia', prefixIcon: Icon(Icons.school_outlined)), items: schools.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => school = v ?? school)),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .72), borderRadius: BorderRadius.circular(24)),
              child: SwitchListTile.adaptive(title: const Text('¿Hablas alguna lengua materna o extranjera?', style: TextStyle(fontWeight: FontWeight.w700)), value: speaksLanguages, activeThumbColor: AppColors.primary, onChanged: (v) => setState(() { speaksLanguages = v; if (!v) selectedLanguages.clear(); })),
            ),
            if (speaksLanguages) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: languages.map((lang) => FilterChip(label: Text(lang), selected: selectedLanguages.contains(lang), selectedColor: AppColors.primaryLight, onSelected: (v) => setState(() => v ? selectedLanguages.add(lang) : selectedLanguages.remove(lang)))).toList()),
            ],
            const SizedBox(height: 34),
            PrimaryButton(
              text: 'Guardar y comenzar test',
              icon: Icons.arrow_forward_rounded,
              onPressed: () async {
                final profile = UserProfile(
                  id: '1',
                  name: extra['name'] ?? 'Aspirante',
                  age: extra['age'] ?? 18,
                  gender: extra['gender'] ?? 'Otro',
                  state: state,
                  school: school,
                  speaksLanguages: speaksLanguages,
                  languagesList: selectedLanguages.toList(),
                  avatarConfig: ref.read(avatarProvider),
                  createdAt: DateTime.now(),
                );
                await ref.read(profileProvider.notifier).saveProfile(profile);
                if (context.mounted) context.go('/path-home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
