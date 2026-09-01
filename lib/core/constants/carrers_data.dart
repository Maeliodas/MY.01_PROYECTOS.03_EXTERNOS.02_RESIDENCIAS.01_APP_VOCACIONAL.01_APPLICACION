import 'riasec_constants.dart';

class CareerData {
  const CareerData({
    required this.id,
    required this.name,
    required this.riasecProfile,
  });

  final String id;
  final String name;
  final Map<RiasecType, double> riasecProfile;
}

abstract final class CareersData {
  static const List<CareerData> careers = [
    CareerData(
      id: 'isc',
      name: 'Ingeniería en Sistemas Computacionales',
      riasecProfile: {
        RiasecType.realistic: 0.70,
        RiasecType.investigative: 1.00,
        RiasecType.artistic: 0.20,
        RiasecType.social: 0.30,
        RiasecType.enterprising: 0.40,
        RiasecType.conventional: 0.80,
      },
    ),

    CareerData(
      id: 'ii',
      name: 'Ingeniería en Informática',
      riasecProfile: {
        RiasecType.realistic: 0.60,
        RiasecType.investigative: 0.95,
        RiasecType.artistic: 0.30,
        RiasecType.social: 0.35,
        RiasecType.enterprising: 0.40,
        RiasecType.conventional: 0.85,
      },
    ),

    CareerData(
      id: 'ida',
      name: 'Ingeniería en Desarrollo de Aplicaciones',
      riasecProfile: {
        RiasecType.realistic: 0.50,
        RiasecType.investigative: 0.90,
        RiasecType.artistic: 0.65,
        RiasecType.social: 0.30,
        RiasecType.enterprising: 0.45,
        RiasecType.conventional: 0.70,
      },
    ),

    CareerData(
      id: 'iem',
      name: 'Ingeniería Electromecánica',
      riasecProfile: {
        RiasecType.realistic: 1.00,
        RiasecType.investigative: 0.80,
        RiasecType.artistic: 0.15,
        RiasecType.social: 0.25,
        RiasecType.enterprising: 0.45,
        RiasecType.conventional: 0.65,
      },
    ),

    CareerData(
      id: 'ie',
      name: 'Ingeniería Electrónica',
      riasecProfile: {
        RiasecType.realistic: 0.90,
        RiasecType.investigative: 0.90,
        RiasecType.artistic: 0.20,
        RiasecType.social: 0.25,
        RiasecType.enterprising: 0.35,
        RiasecType.conventional: 0.70,
      },
    ),

    CareerData(
      id: 'ic',
      name: 'Ingeniería Civil',
      riasecProfile: {
        RiasecType.realistic: 0.95,
        RiasecType.investigative: 0.75,
        RiasecType.artistic: 0.25,
        RiasecType.social: 0.35,
        RiasecType.enterprising: 0.55,
        RiasecType.conventional: 0.65,
      },
    ),

    CareerData(
      id: 'ibq',
      name: 'Ingeniería Bioquímica',
      riasecProfile: {
        RiasecType.realistic: 0.65,
        RiasecType.investigative: 1.00,
        RiasecType.artistic: 0.15,
        RiasecType.social: 0.30,
        RiasecType.enterprising: 0.30,
        RiasecType.conventional: 0.70,
      },
    ),

    CareerData(
      id: 'ige',
      name: 'Ingeniería en Gestión Empresarial',
      riasecProfile: {
        RiasecType.realistic: 0.30,
        RiasecType.investigative: 0.50,
        RiasecType.artistic: 0.35,
        RiasecType.social: 0.70,
        RiasecType.enterprising: 1.00,
        RiasecType.conventional: 0.75,
      },
    ),

    CareerData(
      id: 'la',
      name: 'Licenciatura en Administración',
      riasecProfile: {
        RiasecType.realistic: 0.25,
        RiasecType.investigative: 0.45,
        RiasecType.artistic: 0.30,
        RiasecType.social: 0.75,
        RiasecType.enterprising: 0.95,
        RiasecType.conventional: 0.85,
      },
    ),

    CareerData(
      id: 'cp',
      name: 'Contador Público',
      riasecProfile: {
        RiasecType.realistic: 0.25,
        RiasecType.investigative: 0.60,
        RiasecType.artistic: 0.10,
        RiasecType.social: 0.35,
        RiasecType.enterprising: 0.50,
        RiasecType.conventional: 1.00,
      },
    ),
  ];
}
