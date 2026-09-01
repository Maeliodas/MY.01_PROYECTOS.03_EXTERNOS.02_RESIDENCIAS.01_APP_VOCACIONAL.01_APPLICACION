import '../constants/app_constants.dart';

abstract final class Validators {
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }

    return null;
  }

  static String? name(String? value) {
    final requiredError = required(value, fieldName: 'El nombre');

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 2) {
      return 'El nombre es demasiado corto';
    }

    return null;
  }

  static String? age(int? value) {
    if (value == null) {
      return 'La edad es obligatoria';
    }

    if (value < AppConstants.minimumAge || value > AppConstants.maximumAge) {
      return 'Ingresa una edad válida';
    }

    return null;
  }
}
