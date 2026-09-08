abstract class AppValidators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "Este campo"} es obligatorio';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu edad';
    }
    final age = int.tryParse(value);
    if (age == null || age < 12 || age > 99) {
      return 'Ingresa una edad válida (12-99)';
    }
    return null;
  }
}
