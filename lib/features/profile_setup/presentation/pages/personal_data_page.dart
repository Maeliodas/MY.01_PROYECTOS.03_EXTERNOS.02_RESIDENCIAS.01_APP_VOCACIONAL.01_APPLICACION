import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/profile_setup_provider.dart';

class PersonalDataPage extends ConsumerStatefulWidget {
  const PersonalDataPage({super.key});
  @override
  ConsumerState<PersonalDataPage> createState() => _S();
}

class _S extends ConsumerState<PersonalDataPage> {
  final n = TextEditingController(), a = TextEditingController();
  String? g;
  @override
  void dispose() {
    n.dispose();
    a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Datos personales')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: n,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: a,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Edad'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Género'),
          items: const [
            DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
            DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
            DropdownMenuItem(
              value: 'No especificar',
              child: Text('No especificar'),
            ),
          ],
          onChanged: (v) => setState(() => g = v),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Continuar', onPressed: () => _next()),
      ],
    ),
  );
  void _next() {
    final age = int.tryParse(a.text);
    if (n.text.trim().isEmpty || age == null || g == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los datos solicitados')),
      );
      return;
    }
    ref.read(profileSetupProvider.notifier).state = ref
        .read(profileSetupProvider)
        .copyWith(name: n.text.trim(), age: age, gender: g);
    context.push('/profile/school');
  }
}
