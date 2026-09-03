import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class SimpleAvatarEditorPage extends ConsumerStatefulWidget {
  const SimpleAvatarEditorPage({super.key});

  @override
  ConsumerState<SimpleAvatarEditorPage> createState() =>
      _SimpleAvatarEditorPageState();
}

class _SimpleAvatarEditorPageState extends ConsumerState<SimpleAvatarEditorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Avatar'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Preview del Avatar
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primaryGreen, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const ClipOval(
                  child: Icon(Icons.person,
                      size: 90, color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Pestañas de Personalización
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor: AppColors.primaryGreen,
              tabs: const [
                Tab(text: 'Cabello'),
                Tab(text: 'Ropa'),
                Tab(text: 'Accesorios'),
                Tab(text: 'Color'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOptionGrid(['Lacio', 'Rizado', 'Corto', 'Largo']),
                  _buildOptionGrid(
                      ['Casual', 'Formal', 'Deportivo', 'Estudiantil']),
                  _buildOptionGrid(['Ninguno', 'Lentes', 'Gorra', 'Audífonos']),
                  _buildColorPalette(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: 'Guardar y Continuar',
                onPressed: () => context.push('/personal-data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionGrid(List<String> options) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              options[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      AppColors.primaryGreen,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.brown,
      Colors.black,
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: colors.map((c) {
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }
}
