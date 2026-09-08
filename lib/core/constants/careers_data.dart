class CareersData {
  /// Catálogo local de carreras. Además del código Holland, cada carrera
  /// incluye un perfil RIASEC objetivo y preguntas especialmente
  /// representativas. Esto evita empates artificiales entre carreras que
  /// comparten las mismas letras principales (por ejemplo, Sistemas y
  /// Bioquímica).
  static const initialCareers = [
    {
      'id': 'isc',
      'name': 'Ingeniería en Sistemas Computacionales',
      'description': 'Tecnologías de información, software y resolución de problemas computacionales.',
      'holland_codes': 'I,R,C',
      'riasec_weights': {'R': .58, 'I': 1.0, 'A': .48, 'S': .28, 'E': .34, 'C': .78},
      'question_ids': [6, 10, 14, 27, 28],
    },
    {
      'id': 'ii',
      'name': 'Ingeniería Informática',
      'description': 'Sistemas, datos, infraestructura y soluciones digitales.',
      'holland_codes': 'I,C,R',
      'riasec_weights': {'R': .50, 'I': .92, 'A': .38, 'S': .30, 'E': .38, 'C': .88},
      'question_ids': [6, 10, 27, 28, 29],
    },
    {
      'id': 'idap',
      'name': 'Ingeniería en Desarrollo de Aplicaciones',
      'description': 'Desarrollo de aplicaciones y productos digitales.',
      'holland_codes': 'I,A,R',
      'riasec_weights': {'R': .45, 'I': .92, 'A': .82, 'S': .30, 'E': .34, 'C': .55},
      'question_ids': [6, 10, 11, 14, 15],
    },
    {
      'id': 'iem',
      'name': 'Ingeniería Electromecánica',
      'description': 'Diseño, mantenimiento y operación de sistemas eléctricos y mecánicos.',
      'holland_codes': 'R,I,C',
      'riasec_weights': {'R': 1.0, 'I': .76, 'A': .22, 'S': .18, 'E': .28, 'C': .62},
      'question_ids': [1, 4, 5, 28, 29],
    },
    {
      'id': 'ie',
      'name': 'Ingeniería Electrónica',
      'description': 'Electrónica, circuitos, control y automatización.',
      'holland_codes': 'R,I,C',
      'riasec_weights': {'R': .90, 'I': .88, 'A': .28, 'S': .18, 'E': .25, 'C': .62},
      'question_ids': [1, 4, 5, 6, 10],
    },
    {
      'id': 'ic',
      'name': 'Ingeniería Civil',
      'description': 'Diseño, construcción e infraestructura.',
      'holland_codes': 'R,I,C',
      'riasec_weights': {'R': .92, 'I': .72, 'A': .48, 'S': .28, 'E': .38, 'C': .68},
      'question_ids': [2, 3, 4, 12, 28],
    },
    {
      'id': 'ibq',
      'name': 'Ingeniería Bioquímica',
      'description': 'Procesos biológicos, químicos, experimentación y laboratorio.',
      'holland_codes': 'I,R,C',
      'riasec_weights': {'R': .48, 'I': 1.0, 'A': .20, 'S': .22, 'E': .18, 'C': .64},
      'question_ids': [7, 8, 9, 28, 29],
    },
    {
      'id': 'ige',
      'name': 'Ingeniería en Gestión Empresarial',
      'description': 'Gestión, liderazgo, emprendimiento y estrategia organizacional.',
      'holland_codes': 'E,S,C',
      'riasec_weights': {'R': .20, 'I': .42, 'A': .42, 'S': .72, 'E': 1.0, 'C': .76},
      'question_ids': [21, 22, 23, 24, 25],
    },
    {
      'id': 'la',
      'name': 'Licenciatura en Administración',
      'description': 'Administración, coordinación de personas y organizaciones.',
      'holland_codes': 'E,S,C',
      'riasec_weights': {'R': .15, 'I': .30, 'A': .32, 'S': .78, 'E': .88, 'C': .86},
      'question_ids': [16, 20, 21, 23, 29],
    },
    {
      'id': 'cp',
      'name': 'Contador Público',
      'description': 'Finanzas, auditoría, registros y control contable.',
      'holland_codes': 'C,E,I',
      'riasec_weights': {'R': .12, 'I': .52, 'A': .10, 'S': .30, 'E': .62, 'C': 1.0},
      'question_ids': [26, 27, 28, 29, 30],
    },
    {
      'id': 'arq',
      'name': 'Arquitectura',
      'description': 'Diseño creativo y técnico de espacios habitables.',
      'holland_codes': 'A,R,I',
      'riasec_weights': {'R': .70, 'I': .58, 'A': 1.0, 'S': .28, 'E': .34, 'C': .48},
      'question_ids': [3, 11, 12, 13, 14],
    },
  ];
}
