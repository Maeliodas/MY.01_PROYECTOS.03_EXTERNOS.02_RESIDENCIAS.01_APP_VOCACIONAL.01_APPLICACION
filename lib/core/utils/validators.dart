abstract class Validators {
  static String? validateRequired(String? value, {String fieldName = 'campo'}) {
    if (value == null || value.trim().isEmpty) {
      return 'El $fieldName es requerido.';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu edad.';
    }
    final age = int.tryParse(value);
    if (age == null || age < 12 || age > 99) {
      return 'Ingresa una edad válida (12-99 años).';
    }
    return null;
  }
}
