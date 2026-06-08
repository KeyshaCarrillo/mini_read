# Gestión de Libros

## Catálogo actual

La aplicación consume un endpoint HTTP mediante `BookApiService`. El endpoint configurado por defecto es `/api/books`. En el backend actual, esa ruta devuelve un catálogo mock en memoria.

El modelo actual `Book` contiene:

- ID, título, autor, descripción.
- Categoría y audiencia.
- Color y tiempo estimado.
- Indicador de imágenes inmersivas.
- Lista `pages[]`.

## Lectura actual

`ReadingPage` utiliza un `PageView` sobre `book.pages`. Al cambiar de página, registra `lastPageRead` en `history_reading`.

## Administración

El dashboard permite crear y editar libros mediante la API. Los endpoints administrativos escriben `books/{bookId}` en Firestore. Sin embargo, el listado público principal no devuelve actualmente esos documentos, sino el catálogo mock.

## Portadas, PDFs y Cloudinary

| Recurso | Estado actual | Objetivo |
|---|---|---|
| Portadas | URLs/imágenes de páginas del catálogo | Cloudinary `mini_read/covers/` |
| Contenido | `pages[]` | PDF mediante URL Cloudinary |
| PDFs | No implementado | Cloudinary `mini_read/pdfs/` |
| Banners | No implementado | Cloudinary `mini_read/banners/` |

## Modelo objetivo

El futuro documento `books/{bookId}` debe almacenar solo metadatos y URLs:

`bookId`, `title`, `author`, `description`, `category`, `audience`, `language`, `coverUrl`, `pdfUrl`, `pageCount`, `readingTime`, `rating`, `reviewsCount`, `isPremium`, timestamps.

## Riesgo de migración

`ReadingPage`, `Book`, `BookModel`, dashboard y backend dependen de `pages[]`. La transición a PDF debe ser gradual y conservar compatibilidad mientras existan libros legacy.

