# Mini Read API

API Express lista para Vercel. Protege las rutas privadas con Firebase Auth y usa Firebase Admin para leer/escribir Firestore.

## Variables de entorno en Vercel

Configura estas variables en el proyecto de Vercel:

```bash
FIREBASE_PROJECT_ID=tu-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@tu-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

La llave se obtiene en Firebase Console:

`Configuracion del proyecto > Cuentas de servicio > Generar nueva clave privada`

No subas ese JSON al repositorio.

## Desarrollo local

```bash
cd backend
npm install
npm run dev
```

La API queda en:

```bash
http://localhost:3000/api
```

## Flutter

Cuando publiques en Vercel, usa la URL base con `/api`:

```bash
flutter run --dart-define=BOOKS_API_BASE_URL=https://tu-api.vercel.app/api
```

## Autenticacion

Las rutas privadas requieren un ID token de Firebase Auth:

```http
Authorization: Bearer <firebase_id_token>
```

En Flutter puedes obtenerlo con:

```dart
final token = await FirebaseAuth.instance.currentUser?.getIdToken();
```

## Colecciones usadas

- `users`
- `users/{uid}/perfiles`
- `books`
- `history_reading`
- `ia_chats`
- `token_transactions`

## Endpoints principales

### Salud

```http
GET /api/health
```

### Libros

Lectura publica para que Flutter pueda cargar catalogo:

```http
GET /api/books
GET /api/books/:bookId
```

CRUD de libros solo admin:

```http
POST /api/books
PATCH /api/books/:bookId
DELETE /api/books/:bookId
```

Ejemplo:

```json
{
  "id": "alice",
  "title": "Alicia en el Pais de las Maravillas",
  "author": "Lewis Carroll",
  "category": "Ninos",
  "audience": "Ninos",
  "description": "Fantasia y curiosidad para lectura interactiva.",
  "sourceName": "Mini Read",
  "sourceUrl": "",
  "accentColor": 4285503691,
  "estimatedMinutes": 12,
  "hasImmersiveImages": true,
  "pages": [
    {
      "pageNumber": 1,
      "title": "La madriguera",
      "text": "Alicia sigue una pista inesperada...",
      "imageUrl": "https://..."
    }
  ]
}
```

### Usuario autenticado

```http
GET /api/me
PATCH /api/me
```

### Perfiles

```http
GET /api/profiles
POST /api/profiles
GET /api/profiles/:profileId
PATCH /api/profiles/:profileId
DELETE /api/profiles/:profileId
POST /api/profiles/:profileId/check-in
POST /api/profiles/:profileId/reward-ad
```

### IA y tokens

```http
POST /api/ai/validate
GET /api/token-transactions
```

`POST /api/ai/validate` descuenta tokens con transaccion:

```json
{
  "profileId": "abc",
  "bookId": "alice",
  "pageNumber": 1,
  "type": "page"
}
```

### Historial y chats

```http
GET /api/history-reading
PUT /api/history-reading/:profileId/:bookId
GET /api/ia-chats
POST /api/ia-chats
```

### CRUD admin generico

Solo para usuarios con custom claim `admin: true` o `users/{uid}.role` igual a `admin`/`owner`.

```http
GET /api/admin/:collection
POST /api/admin/:collection
PATCH /api/admin/:collection/:docId
DELETE /api/admin/:collection/:docId
```

Colecciones permitidas:

- `books`
- `users`
- `history_reading`
- `ia_chats`
- `token_transactions`

Para editar perfiles usa las rutas `/api/profiles`, porque son subcolecciones por usuario.
