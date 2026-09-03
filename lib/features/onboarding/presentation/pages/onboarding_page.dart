import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Descubre tu Vocación',
      'subtitle':
          'Explora tus intereses y habilidades con un test vocacional adaptado al TecNM Tuxtepec.',
      'icon': 'school_rounded',
    },
    {
      'title': 'Conoce tus Opciones',
      'subtitle':
          'Recibe un análisis detallado del nivel de afinidad con la oferta académica de la institución.',
      'icon': 'analytics_rounded',
    },
    {
      'title': 'Sin Necesidad de Conexión',
      'subtitle':
          'Realiza la evaluación en cualquier lugar. Toda la prueba funciona de forma 100% local.',
      'icon': 'wifi_off_rounded',
    },
  ];

  IconData _getIconData(String name) {
    switch (name) {
      case 'school_rounded':
        return Icons.school_rounded;
      case 'analytics_rounded':
        return Icons.analytics_rounded;
      case 'wifi_off_rounded':
        return Icons.wifi_off_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/profile-setup'),
                  child: Text(
                    'Omitir',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconData(slide['icon']!),
                            size: 70,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide['title']!,
                          style: AppTextStyles.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['subtitle']!,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryGreen
                          : AppColors.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: _currentPage == _slides.length - 1
                    ? 'Comenzar'
                    : 'Siguiente',
                onPressed: () {
                  if (_currentPage < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    context.go('/profile-setup');
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
