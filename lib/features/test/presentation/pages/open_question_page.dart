import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/test_provider.dart';

class OpenQuestionPage extends ConsumerStatefulWidget {
  const OpenQuestionPage({super.key});
  @override
  ConsumerState<OpenQuestionPage> createState() => _OpenQuestionPageState();
}
class _OpenQuestionPageState extends ConsumerState<OpenQuestionPage> {
  final controller = TextEditingController();
  @override void dispose(){ controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reflexión Final')),
    body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('¿Tomaste el test en serio y respondiste honestamente?', style: TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      Text('Cuéntanos brevemente tus expectativas sobre tu carrera ideal.', style: TextStyle(fontSize: 16, height: 1.4, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68))),
      const SizedBox(height: 24),
      TextField(controller: controller, minLines: 5, maxLines: 7, decoration: const InputDecoration(hintText: 'Escribe tu respuesta aquí...')),
      const Spacer(),
      PrimaryButton(text: 'Finalizar Test', icon: Icons.check_rounded, onPressed: () async { await ref.read(testProvider.notifier).completeTest(controller.text.trim()); if(context.mounted) context.go('/thank-you'); }),
    ])),),
  );
}
