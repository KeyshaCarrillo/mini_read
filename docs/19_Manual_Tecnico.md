# Manual Técnico

## Requisitos

- Flutter compatible con Dart `^3.10.7`.
- Node.js 18 o superior.
- Proyecto Firebase configurado.
- Cuenta Cloudinary con preset unsigned.

## Estructura

```text
mini_read/
├── reading_app/
├── admin_dashboard/
├── backend/
├── firestore.rules
├── firebase.json
└── docs/
```

## Configurar aplicación lectora

```bash
cd reading_app
flutter pub get
flutter run
```

Archivo `reading_app/.env`:

```text
BOOKS_API_BASE_URL=https://book-api-nu-six.vercel.app/api
CLOUDINARY_CLOUD_NAME=deussxkkg
CLOUDINARY_UPLOAD_PRESET=mini_read_unsigned
```

Nota: el código consulta `BOOK_API_BASE_URL` en singular, mientras el `.env` actual define `BOOKS_API_BASE_URL`. Por ello se utiliza actualmente el endpoint por defecto. Debe unificarse el nombre en una corrección futura controlada.

## Configurar backend

```bash
cd backend
npm install
npm run dev
```

Variables requeridas:

```text
FIREBASE_PROJECT_ID
FIREBASE_CLIENT_EMAIL
FIREBASE_PRIVATE_KEY
```

No debe versionarse la clave privada.

## Configurar dashboard

```bash
cd admin_dashboard
flutter pub get
flutter run -d chrome
```

El dashboard usa `AppConstants.apiBaseUrl` para llamar la API.

## Firebase

- Proyecto configurado: `readlevelproject-6e5d3`.
- Reglas versionadas: `firestore.rules`.
- Hosting configurado para `admin_dashboard/build/web`.

No despliegue reglas sin probar los flujos de tokens: el cliente actual realiza escrituras que las reglas estrictas reservan a backend/admin.

## Validación

```bash
cd reading_app
flutter analyze
flutter test
```

## Mantenimiento

- Conservar la separación `domain/data/presentation`.
- Añadir nuevas colecciones mediante repositories y datasources dedicados.
- Evitar seguir ampliando `HomeController` y `FirebaseLibraryDataSource`.
- Mantener Firestore para metadatos y Cloudinary para archivos.

