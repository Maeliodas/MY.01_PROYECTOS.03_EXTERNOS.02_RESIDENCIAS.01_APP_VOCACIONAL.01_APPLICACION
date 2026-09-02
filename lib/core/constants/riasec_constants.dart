enum RiasecType {
  realistic,
  investigative,
  artistic,
  social,
  enterprising,
  conventional,
}

extension RiasecTypeX on RiasecType {
  String get code => ['R', 'I', 'A', 'S', 'E', 'C'][index];
  String get name => [
    'Realista',
    'Investigador',
    'Artístico',
    'Social',
    'Emprendedor',
    'Convencional',
  ][index];
}
