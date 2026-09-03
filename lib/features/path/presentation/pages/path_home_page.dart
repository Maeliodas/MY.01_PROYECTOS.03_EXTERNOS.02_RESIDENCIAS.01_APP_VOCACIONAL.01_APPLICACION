import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importación del tema
import '../../../../app/theme/app_colors.dart';

// Importaciones con ruta relativa ajustada correctamente (subiendo 4 niveles a la raíz de 'features')
import '../../../test/presentation/pages/test_progress_tree_page.dart';
import '../../../result/presentation/pages/result_unlocked_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

// NOTA: Se eliminó 'go_router' porque no se utiliza en este archivo.

class PathHomePage extends ConsumerStatefulWidget {
  const PathHomePage({super.key});

  @override
  ConsumerState<PathHomePage> createState() => _PathHomePageState();
}

class _PathHomePageState extends ConsumerState<PathHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TestProgressTreePage(),
    ResultUnlockedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textGrey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Resultados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
