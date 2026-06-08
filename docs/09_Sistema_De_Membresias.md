# Sistema de Membresías

## Estado real

Actualmente Mini Read utiliza principalmente el campo booleano `users/{uid}.isPremium`. La colección objetivo `memberships/{uid}` está protegida por reglas, pero no existe un datasource ni flujo completo de suscripción.

La aplicación incluye UI para usuario gratuito/premium y un método de upgrade demostrativo. No existe integración de pagos ni control real de dispositivos.

## Propuesta comercial objetivo

| Característica | Free | Plus | Premium |
|---|---:|---:|---:|
| Biblioteca gratuita | Sí | Sí | Sí |
| Catálogo premium | No | Parcial | Completo |
| Dispositivos objetivo | Hasta 2 | Hasta 3 | Hasta 5 |
| Perfiles lectores objetivo | 1 | 2 | 4 |
| Consultas IA | Limitadas por tokens | Ampliadas | Avanzadas/ilimitadas |
| Beneficios adicionales | Básicos | Recompensas mejoradas | Acceso completo |

## Justificación de límites

- **Free:** reduce costo operativo y facilita adquisición de usuarios.
- **Plus:** cubre hogares pequeños y aumenta capacidad IA.
- **Premium:** soporta familias, más dispositivos y experiencia completa.

Estos límites son parte del modelo objetivo, no controles implementados actualmente.

## Modelo Firestore objetivo

```text
memberships/{uid}
  userId
  plan
  status
  startDate
  endDate
  trialUsed
  createdAt
  updatedAt
```

Las reglas permiten lectura al propietario y reservan escritura para backend/admin.

## Escalabilidad y monetización

La separación de membresía respecto a `users` permitirá integrar pasarelas de pago, renovaciones, pruebas, cancelaciones y auditoría. El plan debe aplicarse desde backend para evitar manipulación por clientes.

