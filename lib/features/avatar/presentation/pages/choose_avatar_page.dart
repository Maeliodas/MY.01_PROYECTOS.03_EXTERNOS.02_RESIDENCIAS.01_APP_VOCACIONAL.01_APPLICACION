import 'dart:io';
import '../../../../core/constants/app_constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/institutional_components.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/avatar_provider.dart';
import '../../../../core/widgets/app_back_button.dart';

class ChooseAvatarPage extends ConsumerWidget {
  final bool returnToProfile;
  const ChooseAvatarPage({super.key, this.returnToProfile = false});

  Future<void> _pickGallery(WidgetRef ref) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (picked != null) {
      ref.read(avatarProvider.notifier).selectCustomPhoto(picked.path);
    }
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selectionColor = dark ? AppColors.primaryOnDark : AppColors.primary;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [AppColors.backgroundDark, AppColors.blue900]
                    : const [AppColors.white, AppColors.blue50])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const AppBackButton(),
                  const SizedBox(width: 6),
                  Text(AppConstants.appName,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: selectionColor)),
                ]),
                const SizedBox(height: 12),
                Text(returnToProfile ? 'Cambia tu avatar' : 'Elige tu avatar',
                    style: AppTypography.display.copyWith(
                        color: dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                    'Selecciona un avatar de la app o usa una imagen de tu galería.',
                    textAlign: TextAlign.start,
                    style: AppTypography.body.copyWith(
                        fontSize: 15,
                        height: 1.35,
                        color: dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
                const SizedBox(height: 20),
                const SectionLabel('Avatar de la app'),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 6),
                    itemCount: defaultAvatars.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .92),
                    itemBuilder: (_, i) {
                      final path = defaultAvatars[i];
                      final active = selected.avatarPath == path;
                      return GestureDetector(
                        onTap: () => notifier.selectAvatar(path),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppMetrics.radiusMd + 2),
                            border: Border.all(
                                color: active
                                    ? selectionColor
                                    : (dark
                                        ? AppColors.borderDark
                                        : AppColors.borderGray),
                                width: active ? 3 : 1),
                            boxShadow: active
                                ? (dark
                                    ? AppMetrics.shadowCardDark
                                    : AppMetrics.shadowCard)
                                : null,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppMetrics.radiusMd - 2),
                                  child: Image.asset(path, fit: BoxFit.cover)),
                              if (active)
                                const Positioned(
                                    right: 4,
                                    top: 4,
                                    child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AppColors.primary,
                                        child: Icon(Icons.check_rounded,
                                            color: AppColors.onPrimary,
                                            size: 15))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                const SectionLabel('Foto personal'),
                const SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppMetrics.radiusLg),
                    onTap: () => _pickGallery(ref),
                    child: Container(
                      height: 76,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: dark
                            ? AppColors.surfaceVariantDark
                            : AppColors.blue50.withValues(alpha: .65),
                        borderRadius:
                            BorderRadius.circular(AppMetrics.radiusLg),
                        border: Border.all(
                            color: dark
                                ? AppColors.borderDark
                                : AppColors.borderGray),
                      ),
                      child: Row(
                        children: [
                          if (selected.baseAvatarId == 'custom_photo')
                            Container(
                              width: 54,
                              height: 54,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: selectionColor, width: 2.5)),
                              child: ClipOval(
                                  child: Image.file(File(selected.avatarPath),
                                      fit: BoxFit.cover)),
                            )
                          else
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: dark
                                      ? AppColors.primaryOnDarkContainer
                                      : AppColors.blue100,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.photo_library_rounded,
                                  size: 24,
                                  color: dark
                                      ? AppColors.primaryOnDark
                                      : AppColors.primary),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Elegir desde galería o fotos',
                                    style: AppTypography.title.copyWith(
                                        color: dark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(
                                  selected.baseAvatarId == 'custom_photo'
                                      ? 'Foto personal seleccionada · toca para cambiar'
                                      : 'Usa una imagen que te represente',
                                  style: AppTypography.caption.copyWith(
                                      color: dark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: dark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                    text: returnToProfile ? 'Guardar avatar' : 'Continuar',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _finish(context, ref)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
