import '../../domain/entities/book.dart';
import '../../domain/entities/reader_profile.dart';

class LocalLibraryDataSource {
  Future<List<ReaderProfile>> getProfiles() async {
    return const [
      ReaderProfile(
        id: 'p1',
        name: 'Katherine',
        ageGroup: 'Adultos',
        readingMood: 'Lecturas profundas para desconectar',
        favoriteCategories: ['Romance', 'Drama', 'Suspenso'],
        childMode: false,
        accentColor: 0xFF5B7C62,
      ),
      ReaderProfile(
        id: 'p2',
        name: 'Teen',
        ageGroup: 'Adolescentes',
        readingMood: 'Aventura, misterio y clasicos faciles de seguir',
        favoriteCategories: ['Aventura', 'Suspenso'],
        childMode: false,
        accentColor: 0xFF6FA8C8,
      ),
      ReaderProfile(
        id: 'p3',
        name: 'Mini',
        ageGroup: 'Niños',
        readingMood: 'Historias visuales, cortas y acompanadas',
        favoriteCategories: ['Niños', 'Aventura'],
        childMode: true,
        accentColor: 0xFFE36B5D,
      ),
    ];
  }

  Future<List<Book>> getBooks() async {
    return const [
      Book(
        id: 'pride-prejudice',
        title: 'Orgullo y prejuicio',
        author: 'Jane Austen',
        category: 'Romance',
        audience: 'Adultos',
        description:
            'Una historia sobre primeras impresiones, orgullo familiar y amor con criterio propio.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/1342',
        accentColor: 0xFF9E6A6A,
        estimatedMinutes: 18,
        hasImmersiveImages: false,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'Primeras impresiones',
            body:
                'La llegada de un nuevo vecino cambia el ritmo social de la familia Bennet. En esta version demo, el lector encuentra una escena preparada para probar el lector, las notas y las preguntas a la IA.',
          ),
          BookPage(
            pageNumber: 2,
            title: 'Conversaciones',
            body:
                'Elizabeth observa con atencion lo que otros dan por sentado. La lectura se enfoca en intencion, tono y contexto para que luego el chatbot pueda explicar una pagina especifica.',
          ),
        ],
      ),
      Book(
        id: 'frankenstein',
        title: 'Frankenstein',
        author: 'Mary Shelley',
        category: 'Drama',
        audience: 'Adultos',
        description:
            'Un clasico sobre responsabilidad, soledad y las consecuencias de crear sin cuidar.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/84',
        accentColor: 0xFF637A8B,
        estimatedMinutes: 22,
        hasImmersiveImages: false,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'La ambicion',
            body:
                'Victor persigue una idea enorme sin detenerse a medir su efecto humano. Esta pagina demo permite preguntar a la IA por simbolos, motivaciones y resumen.',
          ),
          BookPage(
            pageNumber: 2,
            title: 'La consecuencia',
            body:
                'La criatura despierta preguntas incomodas sobre abandono y compasion. Aqui el lector puede pedir una explicacion sencilla o una lectura mas profunda.',
          ),
        ],
      ),
      Book(
        id: 'dracula',
        title: 'Drácula',
        author: 'Bram Stoker',
        category: 'Suspenso',
        audience: 'Adultos',
        description:
            'Cartas, diarios y misterio gotico en una historia ideal para lectura guiada por contexto.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/345',
        accentColor: 0xFF7D3F4C,
        estimatedMinutes: 20,
        hasImmersiveImages: false,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'El viaje',
            body:
                'El castillo aparece como un lugar de promesas y advertencias. La atmosfera ayuda a probar preguntas sobre tono, tension y narrador.',
          ),
          BookPage(
            pageNumber: 2,
            title: 'La sospecha',
            body:
                'Los detalles pequenos se vuelven pistas. En la app final, este contexto viajara al backend para limitar la IA al libro seleccionado.',
          ),
        ],
      ),
      Book(
        id: 'yellow-wallpaper',
        title: 'El papel amarillo',
        author: 'Charlotte Perkins Gilman',
        category: 'Drama',
        audience: 'Adultos',
        description:
            'Un relato breve sobre encierro, voz propia y salud mental desde una mirada literaria.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/1952',
        accentColor: 0xFFB08B46,
        estimatedMinutes: 12,
        hasImmersiveImages: false,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'La habitacion',
            body:
                'La narradora describe su entorno con una mezcla de calma y ansiedad. Esta demo prepara el tipo de analisis que la IA puede ofrecer sin salir del texto.',
          ),
          BookPage(
            pageNumber: 2,
            title: 'El patron',
            body:
                'El papel se convierte en foco de interpretacion. Una pregunta por pagina puede ayudar a detectar simbolos y cambios emocionales.',
          ),
        ],
      ),
      Book(
        id: 'odyssey',
        title: 'La Odisea',
        author: 'Homero',
        category: 'Aventura',
        audience: 'Adolescentes',
        description:
            'Un viaje epico con retos, hogar, astucia y decisiones dificiles.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/1727',
        accentColor: 0xFF3D7891,
        estimatedMinutes: 24,
        hasImmersiveImages: false,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'El regreso',
            body:
                'Odiseo quiere volver a casa, pero cada parada lo obliga a elegir entre fuerza, prudencia y paciencia.',
          ),
          BookPage(
            pageNumber: 2,
            title: 'La prueba',
            body:
                'El viaje funciona como aventura y como aprendizaje. La IA puede explicar la escena segun edad y nivel del perfil.',
          ),
        ],
      ),
      Book(
        id: 'alice',
        title: 'Alicia en el País de las Maravillas',
        author: 'Lewis Carroll',
        category: 'Niños',
        audience: 'Niños',
        description:
            'Fantasia, curiosidad y juegos de logica para lectura visual e inmersiva.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/11',
        accentColor: 0xFF6FA8C8,
        estimatedMinutes: 14,
        hasImmersiveImages: true,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'La madriguera',
            body:
                'Alicia sigue una pista inesperada y entra en un mundo donde las reglas parecen cambiar. La pagina invita a observar, imaginar y hacer preguntas.',
            illustration: 'Un tunel brillante con relojes flotando',
          ),
          BookPage(
            pageNumber: 2,
            title: 'Crecer y encoger',
            body:
                'Los cambios de tamano ayudan a hablar de emociones, sorpresa y adaptacion. La lectura infantil puede alternar texto corto con imagen amplia.',
            illustration: 'Una mesa diminuta, una puerta pequena y una llave',
          ),
        ],
      ),
      Book(
        id: 'oz',
        title: 'El maravilloso mago de Oz',
        author: 'L. Frank Baum',
        category: 'Niños',
        audience: 'Niños',
        description:
            'Una aventura sobre amistad, valentia y resolver problemas paso a paso.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/55',
        accentColor: 0xFF5B7C62,
        estimatedMinutes: 16,
        hasImmersiveImages: true,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'El camino',
            body:
                'Dorothy empieza un recorrido nuevo y aprende que avanzar con amigos hace menos dificil lo desconocido.',
            illustration: 'Un camino amarillo atravesando campos verdes',
          ),
          BookPage(
            pageNumber: 2,
            title: 'Los companeros',
            body:
                'Cada personaje desea algo diferente. Esta pagina puede usarse para estimular empatia, memoria y conversacion.',
            illustration:
                'Siluetas caminando juntas hacia una ciudad brillante',
          ),
        ],
      ),
      Book(
        id: 'aesop',
        title: 'Fábulas de Esopo',
        author: 'Esopo',
        category: 'Niños',
        audience: 'Niños',
        description:
            'Relatos breves con moralejas para conversar, comparar y aprender vocabulario.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/11339',
        accentColor: 0xFFE36B5D,
        estimatedMinutes: 10,
        hasImmersiveImages: true,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'Una decision',
            body:
                'Una fabula presenta un problema pequeno con una leccion clara. El lector puede preguntar por la moraleja con palabras sencillas.',
            illustration: 'Un sendero, una sombra y una decision por tomar',
          ),
          BookPage(
            pageNumber: 2,
            title: 'La moraleja',
            body:
                'La app puede cerrar cada fabula con preguntas de comprension, memoria y emociones.',
            illustration: 'Un libro abierto con hojas y luz suave',
          ),
        ],
      ),
      Book(
        id: 'grimms',
        title: 'Cuentos de los hermanos Grimm',
        author: 'Jacob y Wilhelm Grimm',
        category: 'Niños',
        audience: 'Niños',
        description:
            'Cuentos clasicos para leer con acompanamiento y cuidado por edad.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/2591',
        accentColor: 0xFF76608A,
        estimatedMinutes: 13,
        hasImmersiveImages: true,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'El bosque',
            body:
                'El bosque funciona como lugar de reto y aprendizaje. En modo infantil, las preguntas deben ser tranquilas y adaptadas.',
            illustration: 'Un bosque claro con sendero y luces pequenas',
          ),
          BookPage(
            pageNumber: 2,
            title: 'La eleccion',
            body:
                'Los personajes toman decisiones que abren conversaciones sobre causa y consecuencia.',
            illustration: 'Dos caminos suaves marcados con hojas',
          ),
        ],
      ),
      Book(
        id: 'jungle-book',
        title: 'El libro de la selva',
        author: 'Rudyard Kipling',
        category: 'Niños',
        audience: 'Niños',
        description:
            'Aventura, pertenencia y reglas de convivencia para lectura acompanada.',
        sourceName: 'Dominio público / Project Gutenberg',
        sourceUrl: 'https://www.gutenberg.org/ebooks/236',
        accentColor: 0xFF4F7D6B,
        estimatedMinutes: 15,
        hasImmersiveImages: true,
        pages: [
          BookPage(
            pageNumber: 1,
            title: 'Aprender reglas',
            body:
                'El protagonista descubre que cada comunidad tiene formas de cuidarse. La lectura puede trabajar atencion y lenguaje.',
            illustration: 'Hojas grandes, luz entre ramas y una senda',
          ),
          BookPage(
            pageNumber: 2,
            title: 'Pertenecer',
            body:
                'La historia abre preguntas sobre amistad, identidad y respeto por otros.',
            illustration: 'Una escena calida de selva al amanecer',
          ),
        ],
      ),
    ];
  }
}
