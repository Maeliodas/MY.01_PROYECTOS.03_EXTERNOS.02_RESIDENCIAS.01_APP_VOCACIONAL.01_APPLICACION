import 'dart:io';
import '../../../../core/constants/app_constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/avatar_provider.dart';
import '../../../../core/widgets/app_back_button.dart';

class ChooseAvatarPage extends ConsumerWidget {
  final bool returnToProfile;
  const ChooseAvatarPage({super.key, this.returnToProfile = false});

  Future<void> _pickGallery(WidgetRef ref) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (picked != null) ref.read(avatarProvider.notifier).selectCustomPhoto(picked.path);
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    if (!returnToProfile) {
      context.push('/personal-data');
      return;
    }
    final current = ref.read(profileProvider);
    if (current != null) {
      final updated = UserProfile(
        id: current.id,
        name: current.name,
        age: current.age,
        gender: current.gender,
        stateId: current.stateId,
        state: current.state,
        municipalityId: current.municipalityId,
        municipality: current.municipality,
        schoolId: current.schoolId,
        pendingSchoolSuggestionId: current.pendingSchoolSuggestionId,
        school: current.school,
        pendingSchoolName: current.pendingSchoolName,
        speaksLanguages: current.speaksLanguages,
        languageIds: current.languageIds,
        languagesList: current.languagesList,
        avatarConfig: ref.read(avatarProvider),
        createdAt: current.createdAt,
      );
      await ref.read(profileProvider.notifier).saveProfile(updated);
    }
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(avatarProvider);
    final notifier = ref.read(avatarProvider.notifier);
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors: Theme.of(context).brightness == Brightness.dark ? const [Color(0xFF0F160D),Color(0xFF152013),Color(0xFF101B18)] : const [Color(0xFFF4FBF7),Color(0xFFF7FAF8),Color(0xFFEAF7F0)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
            child: Column(children: [
              const Row(children: [AppBackButton(), Text(AppConstants.appName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary))]),
              const SizedBox(height: 10),
              Text(returnToProfile ? 'Cambia tu avatar' : 'Elige tu avatar', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Selecciona un avatar de la app o elige una imagen de tu galería.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.35, color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              if (selected.baseAvatarId == 'custom_photo')
                Container(height: 112, width: 112, margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(5), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 4)), child: ClipOval(child: Image.file(File(selected.avatarPath), fit: BoxFit.cover))),
              Expanded(child: GridView.builder(
                itemCount: defaultAvatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 16, childAspectRatio: .95),
                itemBuilder: (_, i) {
                  final path = defaultAvatars[i]; final active = selected.avatarPath == path;
                  return GestureDetector(onTap: () => notifier.selectAvatar(path), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: .88), borderRadius: BorderRadius.circular(24), border: Border.all(color: active ? AppColors.primary : Colors.transparent, width: 4)), child: Stack(fit: StackFit.expand, children: [ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset(path, fit: BoxFit.cover)), if(active) const Positioned(right: 4, top: 4, child: CircleAvatar(radius: 14, backgroundColor: AppColors.primary, child: Icon(Icons.check_rounded, color: Colors.white, size: 18)))])));
                },
              )),
              SecondaryButton(text: 'Elegir desde galería o fotos', onPressed: () => _pickGallery(ref)),
              const SizedBox(height: 10),
              PrimaryButton(text: returnToProfile ? 'Guardar avatar' : 'Continuar', icon: Icons.arrow_forward_rounded, onPressed: () => _finish(context, ref)),
            ]),
          ),
        ),
      ),
    );
  }
}
