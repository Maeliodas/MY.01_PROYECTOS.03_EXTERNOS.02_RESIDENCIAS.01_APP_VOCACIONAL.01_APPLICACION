import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/avatar_provider.dart';

class SimpleAvatarEditorPage extends ConsumerStatefulWidget {
  const SimpleAvatarEditorPage({super.key});
  @override
  ConsumerState<SimpleAvatarEditorPage> createState() => _SimpleAvatarEditorPageState();
}

class _SimpleAvatarEditorPageState extends ConsumerState<SimpleAvatarEditorPage> {
  final ImagePicker _picker = ImagePicker();
  static const avatars = [
    'assets/avatars/avatar_01.png','assets/avatars/avatar_02.png','assets/avatars/avatar_03.png',
    'assets/avatars/avatar_04.png','assets/avatars/avatar_05.png','assets/avatars/avatar_06.png',
  ];

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
    if (image == null) return;
    ref.read(avatarProvider.notifier).selectCustomPhoto(image.path);
  }

  Widget _preview(String path) {
    if (path.startsWith('assets/')) return Image.asset(path, fit: BoxFit.cover);
    return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 88));
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarProvider);
    final notifier = ref.read(avatarProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selectionColor = dark ? AppColors.primaryOnDark : AppColors.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Editar avatar o foto')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 28), children: [
        Center(child: Container(width: 150, height: 150, padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selectionColor, width: 4)), child: ClipOval(child: _preview(avatar.avatarPath)))),
        const SizedBox(height: 24),
        Text('Avatares de la app', style: AppTypography.headline.copyWith(fontSize: 18, color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        const SizedBox(height: 12),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: avatars.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12), itemBuilder: (_, i) {
          final path = avatars[i]; final selected = avatar.avatarPath == path;
          return InkWell(onTap: () => notifier.selectAvatar(path), borderRadius: BorderRadius.circular(AppMetrics.radiusMd), child: Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppMetrics.radiusMd), border: Border.all(color: selected ? selectionColor : (dark ? AppColors.borderDark : AppColors.borderGray), width: selected ? 3 : 1)), child: ClipRRect(borderRadius: BorderRadius.circular(AppMetrics.radiusMd), child: Image.asset(path, fit: BoxFit.cover))));
        }),
        const SizedBox(height: 24),
        Text('Usar una foto', style: AppTypography.headline.copyWith(fontSize: 18, color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Galería'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(onPressed: () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Cámara'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
        ]),
        const SizedBox(height: 28),
        PrimaryButton(text: 'Guardar', icon: Icons.check_rounded, onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/personal-data'); } }),
      ])),
    );
  }
}
