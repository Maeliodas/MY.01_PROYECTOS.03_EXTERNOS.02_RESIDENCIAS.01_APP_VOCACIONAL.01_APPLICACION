import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle titleLarge(BuildContext context) => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textWhite
            : AppColors.textBlack,
        height: 1.2,
      );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textWhite
            : AppColors.textBlack,
        height: 1.3,
      );

  static TextStyle subtitle(BuildContext context) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      );

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textWhite
            : AppColors.textBlack,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textGrey,
      );

  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get badgeText => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
      );
}
