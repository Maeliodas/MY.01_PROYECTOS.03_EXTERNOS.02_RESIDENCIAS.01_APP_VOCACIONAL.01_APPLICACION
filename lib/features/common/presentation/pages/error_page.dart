import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class ErrorPage extends StatelessWidget {
  final String? errorMessage;

  const ErrorPage({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 80, color: Colors.redAccent),
              const SizedBox(height: 24),
              const Text(
                '¡Ups! Algo salió mal.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage ??
                    'No pudimos conectar con el servidor o cargar la información requerida.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Reintentar',
                onPressed: () => context.go('/splash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
