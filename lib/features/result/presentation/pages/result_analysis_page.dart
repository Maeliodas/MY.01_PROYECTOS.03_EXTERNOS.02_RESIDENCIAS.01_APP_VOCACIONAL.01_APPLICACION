import 'dart:async';
import '../../../../core/constants/app_constants.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';

class ResultAnalysisPage extends StatefulWidget {
  const ResultAnalysisPage({super.key});

  @override
  State<ResultAnalysisPage> createState() => _ResultAnalysisPageState();
}

class _ResultAnalysisPageState extends State<ResultAnalysisPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  Timer? _timer;
  int _messageIndex = 0;

  static const _messages = [
    'Analizando tus respuestas…',
    'Construyendo tu perfil RIASEC…',
    'Comparando afinidades profesionales…',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: .92,
      upperBound: 1.08,
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
    });

    Future<void>.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) context.go('/path-home?tab=1');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [AppColors.backgroundDark, AppColors.blue900]
                : const [AppColors.white, AppColors.blue50],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseController,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: (dark
                                        ? AppColors.primaryOnDark
                                        : AppColors.primary)
                                    .withValues(alpha: .22),
                                blurRadius: 34,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        RotationTransition(
                          turns: _rotateController,
                          child: SizedBox(
                            width: 128,
                            height: 128,
                            child: CircularProgressIndicator(
                              strokeWidth: 8,
                              backgroundColor:
                                  dark ? AppColors.borderDark : AppColors.blue100,
                              valueColor: AlwaysStoppedAnimation(
                                dark ? AppColors.primaryOnDark : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.onPrimary,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
                  const Text(
                    'Tu resultado está casi listo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Text(
                      _messages[_messageIndex],
                      key: ValueKey(_messageIndex),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'RIASEC · ${AppConstants.appName}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: dark ? AppColors.primaryOnDark : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
