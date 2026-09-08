import '../../../core/constants/riasec_constants.dart';
import '../domain/models/question.dart';

abstract class QuestionsData {
  static const List<Question> questions = [
    // R - Realista (5)
    Question(
        id: 1,
        text: '¿Te atrae reparar aparatos eléctricos o mecánicos?',
        dimension: RiasecDimension.realistic),
    Question(
        id: 2,
        text:
            '¿Prefieres las actividades prácticas que requieren esfuerzo físico o trabajo en exteriores?',
        dimension: RiasecDimension.realistic),
    Question(
        id: 3,
        text:
            '¿Te gustaría aprender a interpretar planos de construcción y estructuras arquitectónicas?',
        dimension: RiasecDimension.realistic),
    Question(
        id: 4,
        text: '¿Disfrutas operar maquinaria o herramientas con alta precisión?',
        dimension: RiasecDimension.realistic),
    Question(
        id: 5,
        text:
            '¿Te interesa conocer el funcionamiento interno de motores y circuitos?',
        dimension: RiasecDimension.realistic),

    // I - Investigador (5)
    Question(
        id: 6,
        text:
            '¿Te apasiona encontrar la solución a problemas lógicos o algoritmos complejos?',
        dimension: RiasecDimension.investigative),
    Question(
        id: 7,
        text:
            '¿Te gusta investigar el porqué de los fenómenos naturales o científicos?',
        dimension: RiasecDimension.investigative),
    Question(
        id: 8,
        text:
            '¿Disfrutas analizar datos y realizar experimentos en laboratorios?',
        dimension: RiasecDimension.investigative),
    Question(
        id: 9,
        text:
            '¿Te consideras curioso por comprender sistemas bioquímicos o biológicos?',
        dimension: RiasecDimension.investigative),
    Question(
        id: 10,
        text:
            '¿Te agrada resolver acertijos de programación o ecuaciones complejas?',
        dimension: RiasecDimension.investigative),

    // A - Artístico (5)
    Question(
        id: 11,
        text:
            '¿Prefieres crear algo nuevo desde cero en lugar de seguir un manual ya escrito?',
        dimension: RiasecDimension.artistic),
    Question(
        id: 12,
        text:
            '¿Te gustaría diseñar espacios habitables que sean tanto funcionales como bellos?',
        dimension: RiasecDimension.artistic),
    Question(
        id: 13,
        text:
            '¿Te expresas mejor mediante el dibujo, la música o el diseño gráfico?',
        dimension: RiasecDimension.artistic),
    Question(
        id: 14,
        text:
            '¿Disfrutas proponer soluciones creativas e innovadoras fuera de lo común?',
        dimension: RiasecDimension.artistic),
    Question(
        id: 15,
        text:
            '¿Te atrae el mundo visual, las tendencias estéticas y el arte contemporáneo?',
        dimension: RiasecDimension.artistic),

    // S - Social (5)
    Question(
        id: 16,
        text:
            '¿Disfrutas de asesorar o enseñar a otros sobre temas que tú dominas?',
        dimension: RiasecDimension.social),
    Question(
        id: 17,
        text:
            '¿Te sientes motivado al colaborar con comunidades para resolver problemas sociales?',
        dimension: RiasecDimension.social),
    Question(
        id: 18,
        text:
            '¿Prefieres trabajar directamente con personas guiándolas y apoyándolas?',
        dimension: RiasecDimension.social),
    Question(
        id: 19,
        text:
            '¿Tienes facilidad para escuchar y aconsejar a compañeros en situaciones difíciles?',
        dimension: RiasecDimension.social),
    Question(
        id: 20,
        text:
            '¿Te agrada organizar eventos para promover el bienestar de tu grupo?',
        dimension: RiasecDimension.social),

    // E - Emprendedor (5)
    Question(
        id: 21,
        text:
            '¿Disfrutas de las ventas, la negociación y el trato con proveedores o clientes?',
        dimension: RiasecDimension.enterprising),
    Question(
        id: 22,
        text:
            '¿Te consideras una persona competitiva que busca optimizar recursos para ganar más?',
        dimension: RiasecDimension.enterprising),
    Question(
        id: 23,
        text:
            '¿Te atrae la idea de liderar tu propia empresa o dirigir un equipo de trabajo?',
        dimension: RiasecDimension.enterprising),
    Question(
        id: 24,
        text:
            '¿Tienes facilidad para convencer a otros sobre la viabilidad de tus ideas?',
        dimension: RiasecDimension.enterprising),
    Question(
        id: 25,
        text:
            '¿Te motiva la toma de decisiones estratégicas bajo entornos de oportunidad?',
        dimension: RiasecDimension.enterprising),

    // C - Convencional (5)
    Question(
        id: 26,
        text:
            '¿Te interesa el mundo de los impuestos, las auditorías y las leyes financieras?',
        dimension: RiasecDimension.conventional),
    Question(
        id: 27,
        text:
            '¿Disfrutas organizar archivos, bases de datos o inventarios de forma rigurosa?',
        dimension: RiasecDimension.conventional),
    Question(
        id: 28,
        text:
            '¿Prefieres contar con reglas y procedimientos claros antes de iniciar una tarea?',
        dimension: RiasecDimension.conventional),
    Question(
        id: 29,
        text:
            '¿Te aseguras de mantener tus finanzas y reportes de trabajo en estricto orden?',
        dimension: RiasecDimension.conventional),
    Question(
        id: 30,
        text:
            '¿Te apasiona la precisión de los registros contables y el control administrativo?',
        dimension: RiasecDimension.conventional),
  ];
}
