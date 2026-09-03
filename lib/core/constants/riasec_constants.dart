enum RiasecDimension {
  realistic, // R
  investigative, // I
  artistic, // A
  social, // S
  enterprising, // E
  conventional // C
}

extension RiasecExtension on RiasecDimension {
  String get code {
    switch (this) {
      case RiasecDimension.realistic:
        return 'R';
      case RiasecDimension.investigative:
        return 'I';
      case RiasecDimension.artistic:
        return 'A';
      case RiasecDimension.social:
        return 'S';
      case RiasecDimension.enterprising:
        return 'E';
      case RiasecDimension.conventional:
        return 'C';
    }
  }

  String get nameEs {
    switch (this) {
      case RiasecDimension.realistic:
        return 'Realista';
      case RiasecDimension.investigative:
        return 'Investigador';
      case RiasecDimension.artistic:
        return 'Artístico';
      case RiasecDimension.social:
        return 'Social';
      case RiasecDimension.enterprising:
        return 'Emprendedor';
      case RiasecDimension.conventional:
        return 'Convencional';
    }
  }

  String get description {
    switch (this) {
      case RiasecDimension.realistic:
        return 'Preferencia por actividades prácticas, herramientas, máquinas y trabajo en exteriores.';
      case RiasecDimension.investigative:
        return 'Preferencia por analizar, resolver problemas lógicos, investigación y conocimiento científico.';
      case RiasecDimension.artistic:
        return 'Preferencia por la expresión creativa, diseño, innovación e ideas originales.';
      case RiasecDimension.social:
        return 'Preferencia por ayudar, enseñar, orientar y colaborar con personas.';
      case RiasecDimension.enterprising:
        return 'Preferencia por liderazgo, negocios, toma de decisiones y persuasión.';
      case RiasecDimension.conventional:
        return 'Preferencia por el orden, la organización de datos, procesos y leyes.';
    }
  }
}
