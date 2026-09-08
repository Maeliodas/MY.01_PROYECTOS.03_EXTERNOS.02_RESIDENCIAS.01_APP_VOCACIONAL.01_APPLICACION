import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../avatar/presentation/providers/avatar_provider.dart';

class PersonalDataPage extends ConsumerStatefulWidget {
  const PersonalDataPage({super.key});
  @override
  ConsumerState<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends ConsumerState<PersonalDataPage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController(text: '18');
  String gender = 'Otro';

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarProvider);
    final local = avatar.avatarPath.startsWith('/') || avatar.avatarPath.contains('emulated');
    final image = local
        ? Image.file(File(avatar.avatarPath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 90))
        : Image.asset(avatar.avatarPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 90));

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FFE9), Color(0xFFF4F8E8), Color(0xFFE9FFF7)])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded))),
                const SizedBox(height: 8),
                const Align(alignment: Alignment.centerLeft, child: Text('¡Te ves genial!', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, height: 1))),
                const SizedBox(height: 8),
                const Align(alignment: Alignment.centerLeft, child: Text('Tu camino profesional empieza aquí.', style: TextStyle(fontSize: 17, color: AppColors.textSecondary))),
                const SizedBox(height: 28),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(width: 210, height: 210, padding: const EdgeInsets.all(7), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.primary, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .16), blurRadius: 24, offset: const Offset(0, 12))]), child: ClipOval(child: image)),
                    Positioned(right: 5, bottom: 8, child: Container(width: 48, height: 48, decoration: const BoxDecoration(color: Color(0xFF7633D5), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, color: Colors.white))),
                  ],
                ),
                const SizedBox(height: 34),
                const Align(alignment: Alignment.centerLeft, child: Text('TU NOMBRE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: 1.4))),
                const SizedBox(height: 8),
                TextField(controller: nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded), hintText: 'Escribe tu nombre aquí...')),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad', prefixIcon: Icon(Icons.cake_outlined)))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(initialValue: gender, decoration: const InputDecoration(labelText: 'Género'), items: const [DropdownMenuItem(value: 'Masculino', child: Text('Masculino')), DropdownMenuItem(value: 'Femenino', child: Text('Femenino')), DropdownMenuItem(value: 'Otro', child: Text('Otro'))], onChanged: (v) => setState(() => gender = v ?? 'Otro'))),
                ]),
                const SizedBox(height: 26),
                PrimaryButton(
                  text: 'Continuar',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe tu nombre para continuar.')));
                      return;
                    }
                    context.push('/school-data', extra: {'name': name, 'age': int.tryParse(ageController.text.trim()) ?? 18, 'gender': gender});
                  },
                ),
                const SizedBox(height: 16),
                TextButton.icon(onPressed: () => context.push('/avatar-editor'), icon: const Icon(Icons.edit_outlined), label: const Text('EDITAR AVATAR', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
