# Casos de Uso

## CU-01 Registrar cuenta

| Elemento | Descripción |
|---|---|
| Actor | Visitante |
| Precondición | Correo no registrado |
| Flujo | Introduce correo y contraseña; Firebase crea usuario; Firestore crea `users/{uid}`; app abre onboarding |
| Resultado | Cuenta autenticada |
| Excepciones | Correo inválido, contraseña débil, correo existente |

## CU-02 Iniciar sesión

| Elemento | Descripción |
|---|---|
| Actor | Usuario |
| Precondición | Cuenta existente |
| Flujo | Envía credenciales; Firebase valida; AuthGate carga datos |
| Resultado | Perfil de cuenta visible |
| Excepciones | Credenciales inválidas o usuario deshabilitado |

## CU-03 Crear perfil lector

| Elemento | Descripción |
|---|---|
| Actor | Usuario autenticado |
| Flujo | Define nombre, edad, estado lector y categorías; se guarda perfil legacy |
| Resultado | Perfil activo y catálogo personalizado |
| Restricción actual | Máximo global de cuatro perfiles |

## CU-04 Leer libro

| Elemento | Descripción |
|---|---|
| Actor | Perfil lector |
| Flujo | Selecciona libro, abre detalle, inicia lectura y cambia páginas |
| Resultado | Se actualiza `history_reading` |
| Restricción actual | Lectura basada en `pages[]`, no PDF |

## CU-05 Consultar IA

| Elemento | Descripción |
|---|---|
| Actor | Perfil lector |
| Flujo | Solicita pregunta de página/libro; se valida acceso; se descuentan tokens; se muestra respuesta |
| Resultado | Se registra `ia_chats` |
| Restricción actual | Respuesta simulada local |

## CU-06 Editar identidad

| Elemento | Descripción |
|---|---|
| Actor | Usuario autenticado |
| Flujo | Edita nombre, biografía, géneros y avatar |
| Resultado | Cloudinary aloja imagen y Firestore actualiza `photoUrl` |

## CU-07 Administrar usuarios

| Elemento | Descripción |
|---|---|
| Actor | Admin/Owner |
| Flujo | Inicia sesión en dashboard, busca usuario y modifica rol/premium/bloqueo |
| Resultado | Documento del usuario actualizado |

## CU-08 Administrar libros

| Elemento | Descripción |
|---|---|
| Actor | Admin/Owner |
| Flujo | Crea o edita libro desde dashboard |
| Resultado | Documento `books/{bookId}` actualizado |

## Casos previstos no implementados

- Agregar favorito.
- Publicar reseña.
- Comprar membresía.
- Recuperar contraseña.
- Leer PDF o audiolibro.

