class Validators {
  static String? requiredText(String? v) {
    return v == null || v.trim().isEmpty ? 'Este campo es obligatorio' : null;
  }

  static String? age(String? v) {
    final n = int.tryParse(v ?? '');
    return n == null || n < 10 || n > 100 ? 'Edad inválida' : null;
  }
}
