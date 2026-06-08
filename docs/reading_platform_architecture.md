# Mini Read - Arquitectura de Biblioteca Digital

## Objetivo

Mini Read evoluciona hacia una plataforma de lectura digital con catálogo PDF,
portadas, favoritos, progreso de lectura y preparación para IA. La
implementación mantiene la arquitectura Flutter existente y separa dominio,
datos, servicios y presentación.

## Firebase Storage

```text
books/
  adultos/
  infantil/

covers/
  adultos/
  infantil/
```

- `books/`: almacena PDFs.
- `covers/`: almacena portadas.
- Firestore no almacena archivos, solo rutas y URLs.

## Firestore

### books/{bookId}

```json
{
  "id": "frankenstein",
  "title": "Frankenstein",
  "author": "Mary Shelley",
  "description": "Novela clásica de ciencia ficción.",
  "category": "adultos",
  "audience": "adult",
  "pdfPath": "books/adultos/frankenstein.pdf",
  "pdfUrl": "https://...",
  "coverPath": "covers/adultos/frankenstein.jpg",
  "coverUrl": "https://...",
  "pageCount": 280,
  "language": "Español",
  "rating": 4.8,
  "featured": true,
  "active": true,
  "aiEnabled": false,
  "summary": "",
  "keywords": [],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

Nota: el modelo Dart conserva `pages` como lista textual opcional para cuentos
antiguos y TTS. El conteo real de páginas PDF se representa con `pageCount`.

### users/{uid}/favorites/{bookId}

```json
{
  "bookId": "heidi",
  "title": "Heidi",
  "coverUrl": "https://...",
  "pdfUrl": "https://...",
  "createdAt": "Timestamp"
}
```

### users/{uid}/reading_progress/{bookId}

```json
{
  "bookId": "heidi",
  "currentPage": 5,
  "totalPages": 76,
  "progressPercentage": 0.065,
  "lastReadAt": "Timestamp"
}
```

## Servicios

- `BookSyncService`: sincroniza PDFs y portadas desde Firebase Storage hacia
  Firestore. Debe ejecutarse con permisos de administrador.
- `UserBookService`: gestiona favoritos y progreso de lectura del usuario
  autenticado.
- `TtsService`: narración local con `flutter_tts`, preparado para futuros
  proveedores premium.

## Pantallas

- `BooksScreen`: catálogo con grid responsive, filtros, búsqueda y favoritos.
- `BookDetailsScreen` / `BookDetailPage`: detalle premium con portada,
  sinopsis, rating, páginas, favorito, compartir, leer y escuchar cuento.
- `BookReaderScreen` / `PdfReaderPage`: lector PDF con Syncfusion, progreso y
  restauración de última página.
- `FavoritesScreen`: favoritos del usuario ordenados por fecha reciente.

## Seguridad

- `books` es lectura pública desde Firestore.
- Escritura de `books` solo admin.
- Favoritos y progreso se guardan bajo `users/{uid}` y solo los modifica el
  propietario.
- Storage permite lectura autenticada y escritura administrativa para
  `books/` y `covers/`.

## Preparación para IA

El modelo `Book` incluye:

- `aiEnabled`
- `summary`
- `keywords`

Estos campos permiten activar chat con libro, resumen automático,
recomendaciones y narración premium sin migrar el esquema principal.
