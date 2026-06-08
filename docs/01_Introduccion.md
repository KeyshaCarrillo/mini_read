# Mini Read: Introducción

## Descripción

Mini Read es una plataforma de lectura digital desarrollada con Flutter y Firebase. Su propuesta combina catálogo de libros, perfiles lectores, seguimiento de lectura, personalización de cuenta, gamificación mediante rachas y tokens, y una experiencia de consulta asistida por IA.

El repositorio contiene tres aplicaciones relacionadas:

| Componente | Propósito | Estado |
|---|---|---|
| `reading_app` | Aplicación Flutter para lectores | Implementado |
| `backend` | API Express con Firebase Admin | Implementado parcialmente |
| `admin_dashboard` | Panel administrativo Flutter Web | Implementado |

## Problema que resuelve

Las plataformas tradicionales separan lectura, seguimiento, recomendaciones y asistencia contextual. Mini Read busca reunir estas capacidades en una experiencia accesible, permitiendo que diferentes perfiles de una cuenta mantengan preferencias, rachas y tokens propios.

## Público objetivo

- Lectores infantiles, juveniles y adultos.
- Familias que desean perfiles lectores diferenciados.
- Usuarios que buscan acompañamiento durante la lectura.
- Administradores responsables del catálogo y la operación.

## Objetivos

1. Facilitar el acceso a contenido digital organizado por audiencia y categoría.
2. Personalizar el catálogo mediante preferencias del perfil lector.
3. Registrar actividad y continuidad de lectura.
4. Ofrecer consultas contextuales sobre páginas o libros.
5. Preparar una plataforma escalable para planes Free, Plus y Premium.

## Beneficios actuales

- Registro e inicio de sesión con Firebase Auth.
- Sesión persistente y carga automática de cuenta.
- Catálogo segmentado por audiencia.
- Perfiles lectores con preferencias, tokens y racha.
- Lectura paginada y registro de última página.
- Perfil de cuenta editable con avatar almacenado en Cloudinary.
- Dashboard administrativo para usuarios, libros, tokens e interacciones IA.

## Alcance real y trabajo futuro

El sistema actual lee libros mediante documentos con `pages[]`; la lectura PDF está planificada, pero todavía no implementada. Las colecciones `memberships`, `favorites`, `reviews`, `reading_progress`, `notifications` y `achievements` están contempladas en reglas Firestore, aunque aún no forman parte del flujo funcional principal.

