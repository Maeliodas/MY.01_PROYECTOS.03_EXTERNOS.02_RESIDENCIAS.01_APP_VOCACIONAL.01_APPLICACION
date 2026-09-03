import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../avatar/presentation/providers/avatar_provider.dart';

class PersonalDataPage extends ConsumerStatefulWidget {
  const PersonalDataPage({super.key});

  @override
  ConsumerState<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends ConsumerState<PersonalDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Masculino';

  @override
  Widget build(BuildContext context) {
    final avatarConfig = ref.watch(avatarProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Datos Personales')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AvatarCircle(
                  avatarPath: avatarConfig.avatarPath,
                  radius: 50,
                  onTap: () => context.pop(),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => AppValidators.validateRequired(val,
                      fieldName: 'El nombre'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    border: OutlineInputBorder(),
                  ),
                  validator: AppValidators.validateAge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Masculino', child: Text('Masculino')),
                    DropdownMenuItem(
                        value: 'Femenino', child: Text('Femenino')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Siguiente',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.push(
                        '/school-data',
                        extra: {
                          'name': _nameController.text.trim(),
                          'age': int.parse(_ageController.text.trim()),
                          'gender': _selectedGender,
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
