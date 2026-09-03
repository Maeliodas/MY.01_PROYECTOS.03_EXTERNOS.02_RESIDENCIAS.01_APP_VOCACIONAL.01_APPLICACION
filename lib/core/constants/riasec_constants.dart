enum RiasecDimension {
  R('Realistic', 'Realista',
      'Preferencia por trabajo práctico, objetos, herramientas y exteriores.'),
  I('Investigative', 'Investigador',
      'Interés en resolver problemas abstractos y análisis científico.'),
  A('Artistic', 'Artístico',
      'Inclinación por la expresión creativa, diseño y formas estéticas.'),
  S('Social', 'Social',
      'Enfoque en ayudar, enseñar, orientar y colaborar con otros.'),
  E('Enterprising', 'Emprendedor',
      'Gusto por el liderazgo, la persuasión, negocios y proyectos.'),
  C('Conventional', 'Convencional',
      'Preferencia por el orden, datos, procesos y estructuras claras.');

  final String code;
  final String labelEs;
  final String description;

  const RiasecDimension(this.code, this.labelEs, this.description);
}
