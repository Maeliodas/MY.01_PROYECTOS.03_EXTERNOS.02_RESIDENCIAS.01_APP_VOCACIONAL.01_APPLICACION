import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    height: 1.25,
  );

  static const title = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const subtitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
}
