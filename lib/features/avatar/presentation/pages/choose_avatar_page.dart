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
    final selected = ref.watch(avatarProvider);
    final notifier = ref.read(avatarProvider.notifier);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF7FFE8), Color(0xFFF1F8E4), Color(0xFFE9FFF7)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
            child: Column(
              children: [
                Row(children: [IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)), const Text('Aevum Iter', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF287400)))]),
                const SizedBox(height: 10),
                const Text('Elige tu avatar', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('¿Cómo quieres que te vean en tu\ncamino profesional?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.35, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    itemCount: defaultAvatars.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 22, mainAxisSpacing: 20, childAspectRatio: .86),
                    itemBuilder: (_, i) {
                      final path = defaultAvatars[i];
                      final active = selected.avatarPath == path;
                      return GestureDetector(
                        onTap: () => notifier.selectAvatar(path),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .55),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: active ? AppColors.primary : Colors.transparent, width: 4),
                            boxShadow: active ? [BoxShadow(color: AppColors.primary.withValues(alpha: .18), blurRadius: 16)] : null,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset(path, fit: BoxFit.cover)),
                              if (active) Positioned(right: 4, top: 4, child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 18))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(top: 4, bottom: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF0EAF7), borderRadius: BorderRadius.circular(24)),
                  child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFFD8B6FF), child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF7B2BC2))), SizedBox(width: 12), Expanded(child: Text('¿Quieres algo único?\nPuedes personalizar cada detalle de tu personaje.', style: TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF563D66))))]),
                ),
                SecondaryButton(text: 'Personalizar', onPressed: () => context.push('/avatar-editor')),
                const SizedBox(height: 10),
                PrimaryButton(text: 'Continuar', icon: Icons.arrow_forward_rounded, onPressed: () => context.push('/personal-data')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
