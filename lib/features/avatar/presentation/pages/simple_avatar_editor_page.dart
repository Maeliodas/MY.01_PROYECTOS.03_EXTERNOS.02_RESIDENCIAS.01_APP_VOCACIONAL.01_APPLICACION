import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/avatar_config.dart';
import '../providers/avatar_provider.dart';

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
    final AvatarConfig avatar = ref.watch(avatarProvider);
    final AvatarNotifier avatarNotifier = ref.read(avatarProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Editor de Avatar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // -----------------------------------------------------------
            // PREVISUALIZACIÓN
            // -----------------------------------------------------------
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(child: _buildAvatarPreview(avatar)),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Avatar: ${avatar.baseAvatarId}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------------------
            // PESTAÑAS
            // -----------------------------------------------------------
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Cabello'),
                Tab(text: 'Ropa'),
                Tab(text: 'Accesorios'),
                Tab(text: 'Color'),
              ],
            ),

            // -----------------------------------------------------------
            // OPCIONES
            // -----------------------------------------------------------
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHairTab(avatar, avatarNotifier),
                  _buildOutfitTab(avatar, avatarNotifier),
                  _buildAccessoryTab(avatar, avatarNotifier),
                  _buildColorTab(avatar, avatarNotifier),
                ],
              ),
            ),

            // -----------------------------------------------------------
            // GUARDAR
            // -----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: PrimaryButton(
                text: 'Guardar',
                onPressed: () {
                  // El estado ya está actualizado en el provider.
                  // Navega al siguiente paso del flujo.
                  context.push('/personal-data');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // PREVIEW
  // ---------------------------------------------------------------------
  Widget _buildAvatarPreview(AvatarConfig avatar) {
    return Image.asset(
      avatar.avatarPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
          child: Icon(
            Icons.person,
            size: 90,
            color: _skinToneColor(avatar.skinTone),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // CABELLO
  // ---------------------------------------------------------------------
  Widget _buildHairTab(AvatarConfig avatar, AvatarNotifier notifier) {
    return Column(
      children: [
        Expanded(
          child: _buildOptionGrid(
            options: const ['Lacio', 'Rizado', 'Corto', 'Largo'],
            selectedValue: avatar.hairStyle,
            onSelected: notifier.updateHair,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Color de cabello',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        _buildHorizontalOptions(
          options: const ['black', 'brown', 'blonde', 'red'],
          selectedValue: avatar.hairColor,
          onSelected: notifier.updateHairColor,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // ROPA
  // ---------------------------------------------------------------------
  Widget _buildOutfitTab(AvatarConfig avatar, AvatarNotifier notifier) {
    return _buildOptionGrid(
      options: const ['Casual', 'Formal', 'Deportivo', 'Estudiantil'],
      selectedValue: avatar.outfit,
      onSelected: notifier.updateOutfit,
    );
  }

  // ---------------------------------------------------------------------
  // ACCESORIOS
  // ---------------------------------------------------------------------
  Widget _buildAccessoryTab(AvatarConfig avatar, AvatarNotifier notifier) {
    return _buildOptionGrid(
      options: const ['Ninguno', 'Lentes', 'Gorra', 'Audífonos'],
      selectedValue: avatar.accessory,
      onSelected: notifier.updateAccessory,
    );
  }

  // ---------------------------------------------------------------------
  // TONO DE PIEL
  // ---------------------------------------------------------------------
  Widget _buildColorTab(AvatarConfig avatar, AvatarNotifier notifier) {
    const skinTones = ['light', 'medium', 'tan', 'dark'];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: skinTones.length,
      itemBuilder: (context, index) {
        final tone = skinTones[index];
        final isSelected = avatar.skinTone == tone;

        return GestureDetector(
          onTap: () => notifier.updateSkinTone(tone),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _skinToneColor(tone),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 4,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // GRID DE OPCIONES
  // ---------------------------------------------------------------------
  Widget _buildOptionGrid({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
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
        final option = options[index];
        final normalizedOption = option.toLowerCase();
        final isSelected =
            selectedValue == normalizedOption ||
            selectedValue == option.toLowerCase();

        return GestureDetector(
          onTap: () => onSelected(normalizedOption),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: isSelected ? 6 : 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // OPCIONES HORIZONTALES (colores de cabello)
  // ---------------------------------------------------------------------
  Widget _buildHorizontalOptions({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selectedValue == option;

          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hairColor(option),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 4,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // COLORES AUXILIARES
  // ---------------------------------------------------------------------
  Color _hairColor(String color) {
    switch (color) {
      case 'brown':
        return Colors.brown;
      case 'blonde':
        return const Color(0xFFFFD54F);
      case 'red':
        return Colors.redAccent;
      case 'black':
      default:
        return Colors.black87;
    }
  }

  Color _skinToneColor(String tone) {
    switch (tone) {
      case 'light':
        return const Color(0xFFF6D2B8);
      case 'tan':
        return const Color(0xFFC6865A);
      case 'dark':
        return const Color(0xFF6D4534);
      case 'medium':
      default:
        return const Color(0xFFE0A477);
    }
  }
}
