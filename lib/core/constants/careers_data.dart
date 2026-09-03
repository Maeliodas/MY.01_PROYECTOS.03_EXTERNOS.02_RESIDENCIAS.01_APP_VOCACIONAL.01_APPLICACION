import 'riasec_constants.dart';

class CareerModel {
  final String id;
  final String name;
  final String description;
  final Map<RiasecDimension, double> weights;

  const CareerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.weights,
  });
}

class CareersData {
  static final List<CareerModel> ittuxCareers = [
    CareerModel(
      id: 'isc',
      name: 'Ingeniería en Sistemas Computacionales',
      description:
          'Diseño y desarrollo de software, algoritmos e infraestructura tecnológica.',
      weights: {
        RiasecDimension.I: 0.40,
        RiasecDimension.R: 0.30,
        RiasecDimension.A: 0.15,
        RiasecDimension.C: 0.15,
      },
    ),
    CareerModel(
      id: 'inf',
      name: 'Ingeniería en Informática',
      description:
          'Gestión de tecnologías de la información y sistemas empresariales.',
      weights: {
        RiasecDimension.I: 0.35,
        RiasecDimension.C: 0.35,
        RiasecDimension.E: 0.15,
        RiasecDimension.R: 0.15,
      },
    ),
    CareerModel(
      id: 'ida',
      name: 'Ingeniería en Desarrollo de Aplicaciones',
      description:
          'Especialización en soluciones móviles, web y experiencia de usuario.',
      weights: {
        RiasecDimension.A: 0.35,
        RiasecDimension.I: 0.35,
        RiasecDimension.R: 0.15,
        RiasecDimension.E: 0.15,
      },
    ),
    CareerModel(
      id: 'ime',
      name: 'Ingeniería Electromecánica',
      description:
          'Integración de sistemas mecánicos, eléctricos e industriales.',
      weights: {
        RiasecDimension.R: 0.50,
        RiasecDimension.I: 0.30,
        RiasecDimension.C: 0.20,
      },
    ),
    CareerModel(
      id: 'ele',
      name: 'Ingeniería Electrónica',
      description:
          'Diseño de circuitos, automatización y hardware especializado.',
      weights: {
        RiasecDimension.R: 0.40,
        RiasecDimension.I: 0.40,
        RiasecDimension.C: 0.20,
      },
    ),
    CareerModel(
      id: 'civ',
      name: 'Ingeniería Civil',
      description:
          'Planificación, diseño y construcción de infraestructura urbana.',
      weights: {
        RiasecDimension.R: 0.45,
        RiasecDimension.I: 0.25,
        RiasecDimension.E: 0.15,
        RiasecDimension.C: 0.15,
      },
    ),
    CareerModel(
      id: 'bio',
      name: 'Ingeniería Bioquímica',
      description:
          'Transformación de materiales biológicos en productos de valor.',
      weights: {
        RiasecDimension.I: 0.50,
        RiasecDimension.R: 0.30,
        RiasecDimension.C: 0.20,
      },
    ),
    CareerModel(
      id: 'ige',
      name: 'Ingeniería en Gestión Empresarial',
      description:
          'Optimización de procesos, liderazgo estratégico y negocios.',
      weights: {
        RiasecDimension.E: 0.45,
        RiasecDimension.C: 0.25,
        RiasecDimension.S: 0.15,
        RiasecDimension.I: 0.15,
      },
    ),
    CareerModel(
      id: 'adm',
      name: 'Licenciatura en Administración',
      description:
          'Dirección de organizaciones, recursos humanos y planeación.',
      weights: {
        RiasecDimension.E: 0.40,
        RiasecDimension.S: 0.30,
        RiasecDimension.C: 0.30,
      },
    ),
    CareerModel(
      id: 'cp',
      name: 'Contador Público',
      description:
          'Gestión financiera, auditoría, impuestos y procesos contables.',
      weights: {
        RiasecDimension.C: 0.50,
        RiasecDimension.E: 0.25,
        RiasecDimension.I: 0.25,
      },
    ),
  ];
}
