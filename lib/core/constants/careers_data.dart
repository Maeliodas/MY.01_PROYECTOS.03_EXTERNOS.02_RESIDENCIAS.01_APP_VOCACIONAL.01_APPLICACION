class CareerInfo {
  final String id;
  final String name;
  final String description;
  final String hollandCode; // Código Holland ideal (ej: "IRS", "ECS")
  final Map<String, double>
      riasecWeights; // Ponderaciones para cálculo de afinidad
  final List<String> keySkills;
  final String demandTag;

  const CareerInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.hollandCode,
    required this.riasecWeights,
    required this.keySkills,
    required this.demandTag,
  });
}

abstract class CareersData {
  static const List<CareerInfo> ittuxCareers = [
    CareerInfo(
      id: 'ing_sistemas',
      name: 'Ingeniería en Sistemas Computacionales',
      description:
          'Crea software, administra redes y diseña soluciones tecnológicas complejas.',
      hollandCode: 'IRC',
      riasecWeights: {'I': 0.40, 'R': 0.35, 'C': 0.25},
      keySkills: [
        'Lógica especial',
        'Cálculo sintético',
        'Resolución de problemas'
      ],
      demandTag: 'Alta Demanda +25%',
    ),
    CareerInfo(
      id: 'ing_gestion',
      name: 'Ingeniería en Gestión Empresarial',
      description:
          'Lidera proyectos, gestiona la innovación y optimiza procesos de negocios.',
      hollandCode: 'ECS',
      riasecWeights: {'E': 0.40, 'C': 0.35, 'S': 0.25},
      keySkills: [
        'Liderazgo de equipos',
        'Estrategia comercial',
        'Visión analítica'
      ],
      demandTag: 'Crecimiento Sostenido',
    ),
    CareerInfo(
      id: 'lic_administracion',
      name: 'Licenciatura en Administración',
      description:
          'Organización, planificación y optimización del capital humano y financiero.',
      hollandCode: 'CES',
      riasecWeights: {'C': 0.40, 'E': 0.35, 'S': 0.25},
      keySkills: [
        'Pensamiento estratégico',
        'Gestión financiera',
        'Negociación'
      ],
      demandTag: 'Mercado Estable',
    ),
    CareerInfo(
      id: 'ing_mcatronica',
      name: 'Ingeniería Mecatrónica',
      description:
          'Integra mecánica, electrónica y sistemas computacionales para automatización.',
      hollandCode: 'RIC',
      riasecWeights: {'R': 0.45, 'I': 0.35, 'C': 0.20},
      keySkills: ['Diseño robótico', 'Automatización', 'Física aplicada'],
      demandTag: 'Sector Industrial High-Tech',
    ),
    CareerInfo(
      id: 'ing_civil',
      name: 'Ingeniería Civil',
      description:
          'Diseño, construcción y mantenimiento de infraestructuras y obras urbanas.',
      hollandCode: 'RIE',
      riasecWeights: {'R': 0.45, 'I': 0.30, 'E': 0.25},
      keySkills: ['Diseño estructural', 'Dirección de obra', 'Cálculo físico'],
      demandTag: 'Desarrollo de Infraestructura',
    ),
    CareerInfo(
      id: 'ing_electromecanica',
      name: 'Ingeniería Electromecánica',
      description:
          'Mantenimiento e instalación de sistemas eléctricos y mecánicos industriales.',
      hollandCode: 'RCI',
      riasecWeights: {'R': 0.50, 'C': 0.25, 'I': 0.25},
      keySkills: [
        'Sistemas mecánicos',
        'Redes eléctricas',
        'Mantenimiento industrial'
      ],
      demandTag: 'Demanda Industrial',
    ),
    CareerInfo(
      id: 'ing_bioquimica',
      name: 'Ingeniería Bioquímica',
      description:
          'Transformación de materiales biológicos en productos de alto valor.',
      hollandCode: 'IRC',
      riasecWeights: {'I': 0.45, 'R': 0.30, 'C': 0.25},
      keySkills: [
        'Análisis biológico',
        'Procesos biotecnológicos',
        'Investigación'
      ],
      demandTag: 'Sector Agroalimentario',
    ),
  ];
}
