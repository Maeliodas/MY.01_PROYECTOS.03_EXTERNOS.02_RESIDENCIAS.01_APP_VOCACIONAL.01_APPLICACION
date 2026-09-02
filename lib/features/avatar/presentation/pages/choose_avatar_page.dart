import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/avatar_config.dart';
import '../providers/avatar_provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile_setup/presentation/providers/profile_setup_provider.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/primary_button.dart';

class ChooseAvatarPage extends ConsumerWidget {
  const ChooseAvatarPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final sel = r.watch(selectedAvatarProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Elige tu avatar')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: avatarOptions
                    .map(
                      (a) => Card(
                        child: InkWell(
                          onTap: () =>
                              r.read(selectedAvatarProvider.notifier).state =
                                  a.id,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AvatarCircle(id: a.id, radius: 40),
                              Text(a.label),
                              if (sel == a.id) const Icon(Icons.check_circle),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            PrimaryButton(
              label: 'Continuar',
              onPressed: () async {
                final s = r.read(profileSetupProvider);
                await r
                    .read(profileRepositoryProvider)
                    .save(
                      UserProfile(
                        name: s.name,
                        age: s.age,
                        gender: s.gender,
                        schoolId: s.schoolId,
                        schoolNameSnapshot: s.schoolName,
                        languageIds: s.languageIds,
                        languageNamesSnapshot: s.languageNames,
                        otherLanguage: s.otherLanguage,
                        avatarId: sel,
                      ),
                    );
                r.invalidate(profileProvider);
                if (c.mounted) c.go('/test/intro');
              },
            ),
          ],
        ),
      ),
    );
  }
}
