import '../domain/models/question.dart';
import '../../../core/constants/riasec_constants.dart';

const questionsData = <Question>[
  Question(
    id: 'R1',
    text: 'Me gusta construir, reparar o manipular objetos físicos',
    dimension: RiasecType.realistic,
  ),
  Question(
    id: 'R2',
    text: 'Disfruto realizar actividades prácticas usando herramientas',
    dimension: RiasecType.realistic,
  ),
  Question(
    id: 'R3',
    text: 'Me interesa aprender cómo funcionan máquinas y dispositivos',
    dimension: RiasecType.realistic,
  ),
  Question(
    id: 'R4',
    text: 'Prefiero aprender mediante la práctica y la experimentación',
    dimension: RiasecType.realistic,
  ),
  Question(
    id: 'R5',
    text: 'Me agrada trabajar con materiales, equipos o instalaciones',
    dimension: RiasecType.realistic,
  ),
  Question(
    id: 'I1',
    text: 'Me gusta analizar problemas para encontrar una solución',
    dimension: RiasecType.investigative,
  ),
  Question(
    id: 'I2',
    text: 'Disfruto investigar por qué ocurre un fenómeno',
    dimension: RiasecType.investigative,
  ),
  Question(
    id: 'I3',
    text: 'Me interesa trabajar con datos, lógica o cálculos',
    dimension: RiasecType.investigative,
  ),
  Question(
    id: 'I4',
    text: 'Me gusta formular preguntas y comprobar posibles respuestas',
    dimension: RiasecType.investigative,
  ),
  Question(
    id: 'I5',
    text: 'Disfruto aprender conceptos científicos o tecnológicos',
    dimension: RiasecType.investigative,
  ),
  Question(
    id: 'A1',
    text: 'Me gusta crear diseños, ideas o propuestas originales',
    dimension: RiasecType.artistic,
  ),
  Question(
    id: 'A2',
    text: 'Disfruto encontrar formas diferentes de resolver una tarea',
    dimension: RiasecType.artistic,
  ),
  Question(
    id: 'A3',
    text: 'Me interesa combinar creatividad con tecnología',
    dimension: RiasecType.artistic,
  ),
  Question(
    id: 'A4',
    text: 'Me gusta expresar ideas mediante imágenes, diseño o contenido',
    dimension: RiasecType.artistic,
  ),
  Question(
    id: 'A5',
    text: 'Disfruto imaginar nuevas posibilidades para un proyecto',
    dimension: RiasecType.artistic,
  ),
  Question(
    id: 'S1',
    text: 'Me gusta explicar algo para ayudar a otra persona a comprenderlo',
    dimension: RiasecType.social,
  ),
  Question(
    id: 'S2',
    text: 'Disfruto colaborar con otras personas para alcanzar una meta',
    dimension: RiasecType.social,
  ),
  Question(
    id: 'S3',
    text: 'Me interesa escuchar y comprender las necesidades de los demás',
    dimension: RiasecType.social,
  ),
  Question(
    id: 'S4',
    text: 'Me gusta participar en actividades que benefician a otras personas',
    dimension: RiasecType.social,
  ),
  Question(
    id: 'S5',
    text: 'Disfruto orientar o apoyar a alguien cuando tiene una dificultad',
    dimension: RiasecType.social,
  ),
  Question(
    id: 'E1',
    text: 'Me gusta organizar a un grupo para alcanzar un objetivo',
    dimension: RiasecType.enterprising,
  ),
  Question(
    id: 'E2',
    text: 'Disfruto proponer ideas y convencer a otras personas de participar',
    dimension: RiasecType.enterprising,
  ),
  Question(
    id: 'E3',
    text: 'Me interesa iniciar proyectos y asumir responsabilidades',
    dimension: RiasecType.enterprising,
  ),
  Question(
    id: 'E4',
    text: 'Me gusta tomar decisiones cuando un proyecto necesita avanzar',
    dimension: RiasecType.enterprising,
  ),
  Question(
    id: 'E5',
    text: 'Disfruto presentar propuestas o defender una idea',
    dimension: RiasecType.enterprising,
  ),
  Question(
    id: 'C1',
    text: 'Me gusta organizar información de forma clara y ordenada',
    dimension: RiasecType.conventional,
  ),
  Question(
    id: 'C2',
    text:
        'Disfruto revisar detalles para asegurar que un trabajo esté correcto',
    dimension: RiasecType.conventional,
  ),
  Question(
    id: 'C3',
    text: 'Me interesa trabajar siguiendo procedimientos definidos',
    dimension: RiasecType.conventional,
  ),
  Question(
    id: 'C4',
    text: 'Me gusta clasificar, registrar o administrar información',
    dimension: RiasecType.conventional,
  ),
  Question(
    id: 'C5',
    text: 'Disfruto planificar actividades y llevar un control de ellas',
    dimension: RiasecType.conventional,
  ),
];
