enum RiasecType {
  realistic,
  investigative,
  artistic,
  social,
  enterprising,
  conventional,
}

abstract final class RiasecConstants {
  static const String realisticCode = 'R';
  static const String investigativeCode = 'I';
  static const String artisticCode = 'A';
  static const String socialCode = 'S';
  static const String enterprisingCode = 'E';
  static const String conventionalCode = 'C';

  static const Map<RiasecType, String> names = {
    RiasecType.realistic: 'Realista',
    RiasecType.investigative: 'Investigador',
    RiasecType.artistic: 'Artístico',
    RiasecType.social: 'Social',
    RiasecType.enterprising: 'Emprendedor',
    RiasecType.conventional: 'Convencional',
  };

  static const Map<RiasecType, String> descriptions = {
    RiasecType.realistic:
        'Preferencia por actividades prácticas, técnicas y relacionadas con objetos o herramientas.',

    RiasecType.investigative:
        'Preferencia por investigar, analizar información y resolver problemas.',

    RiasecType.artistic:
        'Preferencia por actividades creativas, expresivas y de diseño.',

    RiasecType.social:
        'Preferencia por ayudar, enseñar, orientar y trabajar con otras personas.',

    RiasecType.enterprising:
        'Preferencia por liderar, persuadir, organizar y tomar decisiones.',

    RiasecType.conventional:
        'Preferencia por organizar información, seguir procedimientos y trabajar con datos.',
  };

  static const List<RiasecType> allTypes = [
    RiasecType.realistic,
    RiasecType.investigative,
    RiasecType.artistic,
    RiasecType.social,
    RiasecType.enterprising,
    RiasecType.conventional,
  ];
}
