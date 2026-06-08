# Roles y Permisos

## Roles actuales

| Rol | Representación | Capacidades |
|---|---|---|
| Usuario | `users/{uid}.role = user` | Acceso a su cuenta y lectura |
| Admin | `role = admin` o custom claim `admin: true` | Gestión operativa |
| Owner | `role = owner` | Privilegios administrativos |

Los perfiles lectores también tienen un campo `role` (`adult`, `child` y lógica parcial para `teen`), pero este rol personaliza contenido; no concede permisos administrativos.

## Permisos cliente Firestore

- El usuario puede leer su cuenta.
- Puede editar campos de identidad permitidos.
- No puede editar `role` ni `isPremium`.
- Puede acceder a sus perfiles legacy y notas.
- Los libros tienen lectura pública.
- Escritura de libros, membresías, tokens y logros está reservada a admin.

## Permisos backend

El backend verifica ID tokens y decide acceso admin mediante:

1. Custom claim `admin: true`.
2. `users/{uid}.role` igual a `admin` u `owner`.

## Dashboard administrativo

El dashboard autentica con Firebase Auth y valida el rol consultando `/api/me`. Un usuario autenticado sin rol administrativo entra en estado `forbidden`.

## Matriz resumida

| Operación | Usuario | Admin/Owner |
|---|---:|---:|
| Leer libros | Sí | Sí |
| Editar identidad propia | Sí | Sí |
| Leer perfiles propios | Sí | Sí |
| Gestionar libros | No | Sí |
| Cambiar premium/rol | No | Sí |
| Gestionar memberships | No | Sí |
| Crear token_transactions | No según reglas | Sí/backend |

