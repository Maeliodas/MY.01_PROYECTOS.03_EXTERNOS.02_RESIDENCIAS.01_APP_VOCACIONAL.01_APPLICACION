import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Tu futuro empieza aquí',
      description:
          'Descubre en 5 minutos qué carrera del TecNM Tuxtepec es para ti.',
      icon: Icons.explore_outlined,
    ),
    OnboardingItem(
      title: 'Aprende sobre ti',
      description:
          'Evaluamos tus intereses y habilidades con un divertido test.',
      icon: Icons.psychology_outlined,
    ),
    OnboardingItem(
      title: 'Logra tus metas',
      description: 'Evita la deserción y elige el camino que te apasiona.',
      icon: Icons.emoji_events_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/choose-avatar'),
                  child: const Text('SALTAR',
                      style: TextStyle(color: AppColors.textGrey)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreenLight
                                .withValues(alpha: 0.2),
                          ),
                          child: Icon(page.icon,
                              size: 60, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.textGrey),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indicador de Puntos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppColors.primaryGreen
                          : AppColors.textLightGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: _currentIndex == _pages.length - 1
                    ? '¡Empezar!'
                    : 'Continuar →',
                onPressed: () {
                  if (_currentIndex < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    context.go('/choose-avatar');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
