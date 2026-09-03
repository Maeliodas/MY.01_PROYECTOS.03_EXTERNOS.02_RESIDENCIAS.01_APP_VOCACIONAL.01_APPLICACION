import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class TestProgressTreePage extends StatelessWidget {
  const TestProgressTreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, Alex', style: AppTextStyles.titleMedium),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryGreenLight,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // Banner de Progreso Global
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROGRESO GENERAL', style: AppTextStyles.badgeText),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tu viaje profesional\nestá despegando.',
                            style: AppTextStyles.titleMedium),
                        Text('85%',
                            style: AppTextStyles.titleLarge
                                .copyWith(color: AppColors.primaryGreen)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Mapa Interactivo / Árbol de Nodos
              Expanded(
                child: ListView(
                  children: [
                    _buildMapNode(
                      title: 'Intereses',
                      status: 'Completado',
                      isCompleted: true,
                      isCurrent: false,
                    ),
                    _buildConnectorLine(isCompleted: true),
                    _buildMapNode(
                      title: 'Habilidades',
                      status: 'Completado',
                      isCompleted: true,
                      isCurrent: false,
                    ),
                    _buildConnectorLine(isCompleted: false),
                    _buildMapNode(
                      title: 'Personalidad',
                      status: 'En curso',
                      isCompleted: false,
                      isCurrent: true,
                    ),
                    _buildConnectorLine(isCompleted: false),
                    _buildMapNode(
                      title: 'Resultado',
                      status: 'Bloqueado',
                      isCompleted: false,
                      isCurrent: false,
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                text: 'Continuar el Prueba',
                onPressed: () => context.go('/test'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapNode({
    required String title,
    required String status,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color iconBg = isCompleted
        ? AppColors.primaryGreen
        : (isCurrent ? AppColors.accentBlue : AppColors.dividerColor);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                  color: AppColors.accentBlue.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Icon(
            isCompleted
                ? Icons.check
                : (isCurrent ? Icons.play_arrow : Icons.lock),
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(status, style: AppTextStyles.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectorLine({required bool isCompleted}) {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
      height: 30,
      width: 3,
      color: isCompleted ? AppColors.primaryGreen : AppColors.dividerColor,
    );
  }
}
