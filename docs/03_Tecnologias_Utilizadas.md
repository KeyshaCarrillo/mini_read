# Tecnologías Utilizadas

## Matriz tecnológica

| Tecnología | Uso real | Justificación |
|---|---|---|
| Flutter | Aplicación móvil y dashboard web | Código multiplataforma y UI consistente |
| Dart | Lenguaje de ambos frontends | Tipado estático e integración nativa con Flutter |
| Firebase Auth | Login, registro y sesión | Gestión segura de identidad |
| Cloud Firestore | Persistencia NoSQL | Consultas en tiempo real y escalabilidad administrada |
| Cloudinary | Carga de avatares | URLs CDN, transformación y gestión de imágenes |
| Node.js | Runtime del backend | Ecosistema amplio y despliegue sencillo |
| Express | API REST | Middleware y rutas ligeras |
| Firebase Admin SDK | Acceso privilegiado backend | Verificación de tokens y operaciones administrativas |
| Provider | Inyección y estado reactivo | Solución simple integrada con Flutter |
| HTTP | Consumo de API y Cloudinary | Comunicación REST |

## Flutter y Dart

`reading_app` y `admin_dashboard` comparten Flutter, pero son proyectos independientes. La aplicación lectora utiliza Material, animaciones, `image_picker`, `share_plus` y `flutter_dotenv`. El dashboard añade gráficos, tablas responsivas y Google Fonts.

## Firebase

Firebase Auth gestiona credenciales de email/contraseña. Firestore almacena datos de cuenta y lectura. Las reglas están versionadas en `firestore.rules`. El backend usa Firebase Admin, por lo que sus operaciones no están limitadas por reglas cliente.

## Cloudinary

La app usa un upload preset unsigned y el endpoint REST de Cloudinary. `CloudinaryService` valida tipo, tamaño máximo de 5 MB y bytes vacíos. Actualmente se utiliza para avatares; portadas, PDFs y banners pertenecen al roadmap.

## Clean Architecture y Repository Pattern

La feature de autenticación presenta capas `presentation`, `domain` y `data`. La feature de biblioteca sigue la misma intención mediante entidades, repositorio, casos de uso y datasources.

La implementación es una aproximación pragmática a Clean Architecture: existe separación de contratos, aunque `HomeController` y `FirebaseLibraryDataSource` todavía concentran lógica de varios subdominios.

