import 'riasec_constants.dart';

class CareerDefinition {
  final String id, name;
  final Map<RiasecType, double> weights;
  const CareerDefinition(this.id, this.name, this.weights);
}

const careersData = <CareerDefinition>[
  CareerDefinition('isc', 'Ingeniería en Sistemas Computacionales', {
    RiasecType.realistic: .45,
    RiasecType.investigative: .95,
    RiasecType.artistic: .2,
    RiasecType.social: .25,
    RiasecType.enterprising: .35,
    RiasecType.conventional: .7,
  }),
  CareerDefinition('info', 'Ingeniería en Informática', {
    RiasecType.realistic: .35,
    RiasecType.investigative: .9,
    RiasecType.artistic: .25,
    RiasecType.social: .25,
    RiasecType.enterprising: .4,
    RiasecType.conventional: .8,
  }),
  CareerDefinition('ida', 'Ingeniería en Desarrollo de Aplicaciones', {
    RiasecType.realistic: .3,
    RiasecType.investigative: .85,
    RiasecType.artistic: .65,
    RiasecType.social: .35,
    RiasecType.enterprising: .4,
    RiasecType.conventional: .55,
  }),
  CareerDefinition('electromecanica', 'Ingeniería Electromecánica', {
    RiasecType.realistic: .95,
    RiasecType.investigative: .7,
    RiasecType.artistic: .1,
    RiasecType.social: .2,
    RiasecType.enterprising: .35,
    RiasecType.conventional: .55,
  }),
  CareerDefinition('electronica', 'Ingeniería Electrónica', {
    RiasecType.realistic: .75,
    RiasecType.investigative: .9,
    RiasecType.artistic: .15,
    RiasecType.social: .2,
    RiasecType.enterprising: .25,
    RiasecType.conventional: .55,
  }),
  CareerDefinition('civil', 'Ingeniería Civil', {
    RiasecType.realistic: .9,
    RiasecType.investigative: .65,
    RiasecType.artistic: .3,
    RiasecType.social: .25,
    RiasecType.enterprising: .45,
    RiasecType.conventional: .5,
  }),
  CareerDefinition('bioquimica', 'Ingeniería Bioquímica', {
    RiasecType.realistic: .45,
    RiasecType.investigative: .95,
    RiasecType.artistic: .15,
    RiasecType.social: .35,
    RiasecType.enterprising: .2,
    RiasecType.conventional: .55,
  }),
  CareerDefinition('gestion', 'Ingeniería en Gestión Empresarial', {
    RiasecType.realistic: .15,
    RiasecType.investigative: .4,
    RiasecType.artistic: .25,
    RiasecType.social: .65,
    RiasecType.enterprising: .95,
    RiasecType.conventional: .75,
  }),
  CareerDefinition('administracion', 'Licenciatura en Administración', {
    RiasecType.realistic: .1,
    RiasecType.investigative: .3,
    RiasecType.artistic: .25,
    RiasecType.social: .75,
    RiasecType.enterprising: .9,
    RiasecType.conventional: .85,
  }),
  CareerDefinition('contador', 'Contador Público', {
    RiasecType.realistic: .1,
    RiasecType.investigative: .55,
    RiasecType.artistic: .05,
    RiasecType.social: .3,
    RiasecType.enterprising: .55,
    RiasecType.conventional: .98,
  }),
];
