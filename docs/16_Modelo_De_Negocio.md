# Modelo de Negocio

## Propuesta de valor

Mini Read combina lectura digital, personalización por perfil, seguimiento y asistencia contextual. El modelo busca convertir usuarios gratuitos en suscriptores mediante mayor acceso, más perfiles y capacidad IA.

## Segmentos

- Lectores individuales.
- Familias con perfiles diferenciados.
- Público infantil con contenido filtrado.
- Lectores frecuentes interesados en IA y gamificación.

## Planes objetivo

| Plan | Propuesta | Monetización |
|---|---|---|
| Free | Acceso inicial, tokens limitados y un perfil | Adquisición y anuncios/recompensas |
| Plus | Más perfiles, dispositivos y capacidad IA | Suscripción intermedia |
| Premium | Catálogo completo, familia e IA avanzada | Suscripción principal |

## Implementación actual

El comportamiento premium se controla con `users/{uid}.isPremium`. La experiencia incluye tokens para usuarios gratuitos, recompensa por anuncio simulada y acceso sin costo de tokens para premium.

No existe todavía:

- Pasarela de pago.
- Renovación automática.
- Control real de dispositivos.
- Colección `memberships` consumida por la app.
- Facturación o recibos.

## Escalabilidad

La futura colección `memberships` permitirá separar identidad y suscripción. El backend debe ser la autoridad sobre plan, fechas, estado y límites.

## Fuentes futuras de ingreso

- Suscripciones Plus y Premium.
- Contenido editorial premium.
- Audiolibros.
- Paquetes educativos.
- Alianzas con autores/editoriales.
- Publicidad recompensada para usuarios Free.

