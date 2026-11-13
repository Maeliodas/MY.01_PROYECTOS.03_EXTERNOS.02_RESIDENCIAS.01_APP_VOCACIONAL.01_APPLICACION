import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_metrics.dart';
import 'app_typography.dart';

/// Temas claro y oscuro institucionales (MIG TecNM 2026).
///
/// El azul institucional `#1B396A` lidera acciones y elementos de identidad;
/// los fondos y superficies son neutros (blancos/grises en claro,
/// azul-negro neutro en oscuro) para no saturar la interfaz de azul.
class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static TextTheme _textTheme(bool dark) {
    final textPrimary = dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    return TextTheme(
      displayLarge: AppTypography.display.copyWith(
        fontSize: 32,
        color: textPrimary,
      ),
      displayMedium: AppTypography.display.copyWith(color: textPrimary),
      headlineMedium: AppTypography.headline.copyWith(color: textPrimary),
      headlineSmall: AppTypography.headline.copyWith(
        fontSize: 18,
        color: textPrimary,
      ),
      titleLarge: AppTypography.title.copyWith(fontSize: 17, color: textPrimary),
      titleMedium: AppTypography.title.copyWith(color: textPrimary),
      titleSmall: AppTypography.title.copyWith(
        fontSize: 14,
        color: textPrimary,
      ),
      bodyLarge: AppTypography.body.copyWith(fontSize: 15, color: textPrimary),
      bodyMedium: AppTypography.body.copyWith(color: textPrimary),
      bodySmall: AppTypography.caption.copyWith(color: textSecondary),
      labelLarge: AppTypography.button.copyWith(color: AppColors.onPrimary),
      labelMedium: AppTypography.badge.copyWith(color: textPrimary),
      labelSmall: AppTypography.micro.copyWith(color: textSecondary),
    );
  }

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? AppColors.backgroundDark : AppColors.background;
    final surface = dark
        ? AppColors.cardBackgroundDark
        : AppColors.cardBackground;
    final surfaceVariant = dark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariant;
    final textPrimary = dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final border = dark ? AppColors.borderDark : AppColors.borderGray;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: dark
          ? AppColors.primaryOnDarkContainer
          : AppColors.primaryLight,
      onPrimaryContainer: dark
          ? AppColors.primaryOnDark
          : AppColors.primaryDarker,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: dark
          ? AppColors.primaryOnDarkContainer
          : AppColors.secondaryLight,
      onSecondaryContainer: dark
          ? AppColors.primaryOnDark
          : AppColors.primaryDarker,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: surfaceVariant,
      outline: border,
      outlineVariant: border,
      error: AppColors.destructiveRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppFonts.family,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      cardColor: surface,
      dividerColor: border,
      disabledColor: dark ? const Color(0xFF5A6472) : AppColors.gray400,
      textTheme: _textTheme(dark),
      splashFactory: InkSparkle.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: .45),
          disabledForegroundColor: Colors.white70,
          elevation: dark ? 0 : 1,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.radiusButton),
          ),
          textStyle: AppTypography.button.copyWith(color: AppColors.onPrimary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: .45),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.radiusButton),
          ),
          textStyle: AppTypography.button.copyWith(color: AppColors.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? AppColors.primaryOnDark : AppColors.primary,
          side: BorderSide(
            color: dark ? AppColors.primaryOnDark : AppColors.primary,
            width: 1.4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.radiusButton),
          ),
          textStyle: AppTypography.button.copyWith(
            color: dark ? AppColors.primaryOnDark : AppColors.primary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? AppColors.primaryOnDark : AppColors.primary,
          textStyle: AppTypography.button.copyWith(
            color: dark ? AppColors.primaryOnDark : AppColors.primary,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: textPrimary,
        titleTextStyle: AppTypography.headline.copyWith(
          fontSize: 19,
          color: textPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusXl),
        ),
        titleTextStyle: AppTypography.headline.copyWith(
          fontSize: 21,
          color: textPrimary,
        ),
        contentTextStyle: AppTypography.body.copyWith(color: textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppMetrics.navBarHeight,
        backgroundColor: surface,
        indicatorColor: AppColors.primary,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.badge.copyWith(
            fontSize: 10.5,
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : textSecondary,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: dark ? AppColors.borderDark : AppColors.blue100,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: dark ? AppColors.borderDark : AppColors.blue100,
        thumbColor: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark
            ? AppColors.surfaceVariantDark
            : Colors.white.withValues(alpha: .92),
        hintStyle: AppTypography.body.copyWith(color: textSecondary),
        labelStyle: AppTypography.body.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
          borderSide: const BorderSide(color: AppColors.destructiveRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.destructiveRed,
            width: 1.6,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
        subtitleTextStyle: AppTypography.caption.copyWith(
          color: textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: AppTypography.badge.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusChip),
        ),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppColors.surfaceVariantDark : AppColors.gray900,
        contentTextStyle: AppTypography.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        side: BorderSide(color: border, width: 1.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm - 2),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : border,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
        ),
        textStyle: AppTypography.body.copyWith(color: textPrimary),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : (dark ? AppColors.borderDark : AppColors.gray300),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: .85)
              : (dark ? AppColors.surfaceVariantDark : AppColors.gray200),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTypography.body.copyWith(color: textPrimary),
      ),
    );
  }
}
