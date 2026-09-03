import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../providers/avatar_provider.dart';

class ChooseAvatarPage extends ConsumerWidget {
  const ChooseAvatarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedConfig = ref.watch(avatarProvider);
    final avatarNotifier = ref.read(avatarProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aevum Iter'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Elige tu avatar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Cómo quieres que te vean en tu camino profesional?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Grid de Avatares
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: defaultAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarPath = defaultAvatars[index];
                    final isSelected = selectedConfig.avatarPath == avatarPath;

                    return GestureDetector(
                      onTap: () => avatarNotifier.selectAvatar(avatarPath),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            width: 3,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Image.asset(
                            avatarPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryGreenLight
                                  .withValues(alpha: 0.2),
                              child: const Icon(Icons.person,
                                  size: 60, color: AppColors.primaryGreen),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              // Botón opcional para personalizar
              SecondaryButton(
                text: 'Personalizar Avatar',
                onPressed: () => context.push('/avatar-editor'),
              ),
              const SizedBox(height: 12),
              // Continuar a Datos Personales
              PrimaryButton(
                text: 'Continuar',
                onPressed: () => context.push('/personal-data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
