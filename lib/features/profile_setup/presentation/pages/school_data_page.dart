import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class SchoolDataPage extends StatefulWidget {
  const SchoolDataPage({super.key});

  @override
  State<SchoolDataPage> createState() => _SchoolDataPageState();
}

class _SchoolDataPageState extends State<SchoolDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolController = TextEditingController();
  String _selectedLanguage = 'Español';

  final List<String> _languageOptions = [
    'Español',
    'Chinanteco',
    'Mazateco',
    'Zapoteco',
    'Mixe',
    'Otro',
  ];

  @override
  void dispose() {
    _schoolController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      context.go('/choose-avatar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procedencia', style: AppTextStyles.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryGreen, size: 20),
          onPressed: () => context.go('/profile-setup'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Origen Académico',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Datos estadísticos para el análisis de cobertura de la institución.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Escuela de Procedencia',
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _schoolController,
                          decoration: InputDecoration(
                            hintText: 'Ej. CBTis 107 / COBAO 07',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu escuela de procedencia';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text('Lengua Materna / Originaria',
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              isExpanded: true,
                              items: _languageOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: AppTextStyles.bodyLarge),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedLanguage = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PrimaryButton(
                  text: 'Siguiente',
                  onPressed: _onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
