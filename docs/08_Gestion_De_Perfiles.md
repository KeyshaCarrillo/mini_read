# Gestión de Perfiles

## Dos conceptos distintos

Mini Read diferencia:

- **Cuenta autenticada:** documento `users/{uid}`, con email, nombre, foto y rol.
- **Perfil lector:** subdocumento `users/{uid}/perfiles/{profileId}`, con preferencias, tokens y racha.

## Implementación actual

Los perfiles lectores utilizan la estructura legacy:

```text
users/{uid}/perfiles/{profileId}
```

El modelo `ReaderProfile` incluye nombre, avatar, rol, edad, estado de ánimo lector, categorías favoritas, tokens, racha y color.

## Creación y selección

El onboarding crea un perfil lector con un ID basado en timestamp. `HomeController` mantiene `activeProfile` y personaliza el catálogo según audiencia y categorías.

Aunque existe inspiración en Netflix Profiles, la pantalla denominada `ProfileSelectionPage` actualmente presenta la cuenta del lector, estadísticas y configuración; ya no funciona como una pantalla “¿Quién va a leer?”.

## Avatares

- Avatar de cuenta: Cloudinary y URL en `users/{uid}.photoUrl`.
- Avatar de perfil lector: Cloudinary y URL en `users/{uid}/perfiles/{profileId}.avatarUrl`.
- Cada subida usa un `publicId` con timestamp para evitar conservar una imagen anterior.

## Personalización

La cuenta puede editar nombre de lector, biografía, géneros favoritos y foto. El modal mantiene la imagen en memoria y evita reconstrucciones por escritura en campos de texto.

## Progreso individual

El progreso actual se asocia con `profileId` dentro de `history_reading`. Esto permite diferenciar la página leída por perfil, aunque todavía no se usa la colección objetivo `reading_progress`.

## Límites

El controlador actual define un máximo global de cuatro perfiles. Los límites específicos por plan todavía no se aplican mediante `memberships`.

