import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreenLight.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.check_circle,
                    size: 70, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Gracias por responder!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tus datos han sido procesados. Ya puedes descubrir tu vocación y las carreras más afines.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Ver mis resultados',
                onPressed: () => context.go('/path-home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
