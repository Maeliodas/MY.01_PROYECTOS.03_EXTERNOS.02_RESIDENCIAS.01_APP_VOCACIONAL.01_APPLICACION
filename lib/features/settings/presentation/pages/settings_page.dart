import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_metrics.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/institutional_components.dart';
import '../../../../core/widgets/institutional_logos.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/settings_provider.dart';
import 'privacy_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final reduce = ref.watch(reduceAnimationsProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        children: [
          const SectionLabel('Preferencias'),
          const SizedBox(height: 10),
          InstitutionalCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Switch(icon: Icons.dark_mode_outlined, iconColor: AppColors.secondary, title: 'Modo Oscuro', subtitle: 'Reduce la fatiga visual', value: themeMode == ThemeMode.dark, onChanged: (v) => ref.read(themeModeProvider.notifier).toggleTheme(v)),
                const Divider(height: 1, indent: 70),
                _Switch(icon: Icons.animation_rounded, iconColor: AppColors.secondary, title: 'Disminuir Animaciones', subtitle: 'Reduce los efectos de movimiento', value: reduce, onChanged: (v) => ref.read(reduceAnimationsProvider.notifier).toggleReduce(v)),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionLabel('Datos y catálogos'),
          const SizedBox(height: 10),
          InstitutionalCard(
            padding: EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: dark ? AppColors.surfaceVariantDark : AppColors.blue50, borderRadius: BorderRadius.circular(AppMetrics.radiusMd)), child: Icon(Icons.sync_rounded, color: dark ? AppColors.primaryOnDark : AppColors.primary)),
              title: Text('Actualizar catálogos', style: AppTypography.bodyStrong.copyWith(color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              subtitle: Text('Descarga cambios aprobados del panel y los guarda en SQLite.', style: AppTypography.caption.copyWith(color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                // Pantalla de espera: la descarga por ngrok puede tardar varios
                // segundos y sin indicador parece que la app se trabó.
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => AlertDialog(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.8),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            'Actualizando catálogos…',
                            style: TextStyle(
                              color: Theme.of(dialogContext).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                bool ok = false;
                try {
                  ok = await ref
                      .read(catalogSyncServiceProvider)
                      .sync()
                      .timeout(const Duration(seconds: 60));
                } catch (_) {
                  ok = false;
                } finally {
                  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
                }
                if (ok) {
                  ref.invalidate(statesProvider);
                  ref.invalidate(schoolsProvider);
                  ref.invalidate(allLanguagesProvider);
                  ref.invalidate(careersCatalogProvider);
                  ref.invalidate(departmentQuestionsProvider);
                }
                messenger.showSnackBar(SnackBar(content: Text(ok ? 'Catálogos actualizados.' : 'No fue posible actualizar. Se conservaron los datos locales.')));
              },
            )),
          ),
          const SizedBox(height: 26),
          const SectionLabel('Privacidad y soporte'),
          const SizedBox(height: 10),
          InstitutionalCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Info(icon: Icons.lock_outline_rounded, iconColor: AppColors.secondary, title: 'Aviso de privacidad', subtitle: 'Consulta qué datos utiliza ${AppConstants.appName} y para qué fines.', onTap: () => showPrivacyNoticeDialog(context)),
                const Divider(height: 1, indent: 70),
                const _Info(icon: Icons.help_outline_rounded, iconColor: AppColors.secondary, title: 'Ayuda', subtitle: '${AppConstants.appName} · Prototipo funcional'),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const Center(
            child: InstitutionalFooter(
              caption: '${AppConstants.appName} · TUXTEPEC',
              scale: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Switch({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      secondary: Container(width: 42, height: 42, decoration: BoxDecoration(color: dark ? AppColors.surfaceVariantDark : AppColors.blue50, borderRadius: BorderRadius.circular(AppMetrics.radiusMd)), child: Icon(icon, color: iconColor)),
      title: Text(title, style: AppTypography.bodyStrong.copyWith(color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
      subtitle: Text(subtitle, style: AppTypography.caption.copyWith(color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
      activeThumbColor: AppColors.primary,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _Info({required this.icon, required this.iconColor, required this.title, required this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: dark ? AppColors.surfaceVariantDark : AppColors.blue50, borderRadius: BorderRadius.circular(AppMetrics.radiusMd)), child: Icon(icon, color: iconColor)),
        title: Text(title, style: AppTypography.bodyStrong.copyWith(color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        subtitle: Text(subtitle, style: AppTypography.caption.copyWith(color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
