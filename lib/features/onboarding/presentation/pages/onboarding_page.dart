import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class _OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  const _OnboardingItem(this.title, this.description, this.icon, this.accent);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int index = 0;

  final pages = const [
    _OnboardingItem('Tu futuro empieza\naquí', 'Descubre qué carrera del TecNM Tuxtepec es para ti.', Icons.landscape_rounded, Color(0xFF83CF33)),
    _OnboardingItem('Aprende sobre ti', 'Evaluamos tus intereses y habilidades con un divertido test.', Icons.lightbulb_rounded, Color(0xFF4DAEED)),
    _OnboardingItem('Logra tus metas', 'Evita la deserción y elige el camino que te apasiona.', Icons.emoji_events_rounded, Color(0xFF8D3DDF)),
  ];

  void next() {
    if (index == pages.length - 1) {
      context.go('/choose-avatar');
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF7FFE8), Color(0xFFF4FAE8), Color(0xFFE8FFF7)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      IconButton(onPressed: () => _controller.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut), icon: const Icon(Icons.arrow_back_rounded)),
                    const Text('Aevum Iter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF287400))),
                    const Spacer(),
                    TextButton(onPressed: () => context.go('/choose-avatar'), child: const Text('SALTAR', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF287400), letterSpacing: 1))),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (v) => setState(() => index = v),
                    itemBuilder: (_, i) {
                      final p = pages[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 260,
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .15), blurRadius: 28, offset: const Offset(0, 14))],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 180,
                                  height: 145,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [p.accent.withValues(alpha: .16), const Color(0xFFFFF0D8)]),
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                Icon(p.icon, size: 90, color: p.accent),
                                if (i == 1) ...[
                                  const Positioned(right: 32, top: 32, child: _MiniBadge(icon: Icons.psychology_rounded, color: Color(0xFF8D3DDF))),
                                  const Positioned(left: 28, bottom: 34, child: _MiniBadge(icon: Icons.construction_rounded, color: Color(0xFF20A9E8))),
                                ],
                                if (i == 2) ...[
                                  const Positioned(right: 34, top: 48, child: _MiniBadge(icon: Icons.check_circle_rounded, color: AppColors.primary)),
                                  const Positioned(left: 34, bottom: 54, child: _MiniBadge(icon: Icons.rocket_launch_rounded, color: Color(0xFF20A9E8))),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 34),
                          Text(p.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, height: 1.02, fontWeight: FontWeight.w900, color: Color(0xFF101510))),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(p.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.4, color: Color(0xFF5D6258))),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == index ? 34 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: i == index ? AppColors.primary : const Color(0xFFDDE5D2), borderRadius: BorderRadius.circular(12)),
                  )),
                ),
                const SizedBox(height: 26),
                PrimaryButton(text: index == pages.length - 1 ? '¡Empezar!' : 'Continuar', icon: Icons.arrow_forward_rounded, onPressed: next),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MiniBadge({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: .25), blurRadius: 12)]),
    child: Icon(icon, color: Colors.white, size: 24),
  );
}
