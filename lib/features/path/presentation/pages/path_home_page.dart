import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../result/presentation/pages/result_unlocked_page.dart';
import '../../../test/presentation/pages/test_progress_tree_page.dart';

class PathHomePage extends ConsumerStatefulWidget {
  final int initialIndex;

  const PathHomePage({super.key, this.initialIndex = 0});

  @override
  ConsumerState<PathHomePage> createState() => _PathHomePageState();
}

class _PathHomePageState extends ConsumerState<PathHomePage> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex.clamp(0, 2).toInt();
  }

  void _selectTab(int value) {
    if (value == index) return;
    setState(() => index = value);
  }

  void _showResultFromMap() {
    if (index != 1) {
      setState(() => index = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TestProgressTreePage(onShowResult: _showResultFromMap),
      const ResultUnlockedPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: _FigmaTabBar(
        currentIndex: index,
        onTap: _selectTab,
      ),
    );
  }
}

class _FigmaTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FigmaTabBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: .98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: dark ? const Color(0xFF33402F) : const Color(0xFFE4ECD9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? .22 : .08),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabItem(
                selected: currentIndex == 0,
                icon: Icons.map_outlined,
                selectedIcon: Icons.map_rounded,
                label: 'PATH',
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              child: _TabItem(
                selected: currentIndex == 1,
                icon: Icons.insights_outlined,
                selectedIcon: Icons.insights_rounded,
                label: 'RESULTADOS',
                onTap: () => onTap(1),
              ),
            ),
            Expanded(
              child: _TabItem(
                selected: currentIndex == 2,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'PERFIL',
                onTap: () => onTap(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  const _TabItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary =
        scheme.onSurface.withValues(alpha: .55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(19),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: AnimatedScale(
            scale: selected ? 1.0 : .96,
            duration: const Duration(milliseconds: 220),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: selected ? 23 : 21,
                  color: selected ? const Color(0xFF17340A) : secondary,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: label == 'RESULTADOS' ? 8.2 : 9.3,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .35,
                    color: selected ? const Color(0xFF17340A) : secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
