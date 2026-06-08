# Seguridad

## Autenticación

Firebase Auth administra credenciales. El backend recibe ID tokens mediante:

```http
Authorization: Bearer <firebase_id_token>
```

`requireAuth` verifica el token con Firebase Admin. `requireAdmin` valida claim o rol.

## Reglas Firestore

Las reglas están versionadas en `firestore.rules`. Sus principios:

- Denegación global por defecto.
- Ownership mediante UID.
- Lectura pública de libros.
- Escritura administrativa de libros.
- Campos sensibles de usuario protegidos.
- Membresías y tokens reservados a backend/admin.
- Compatibilidad temporal entre perfiles legacy y `profiles` V2.

## Protección de archivos

Cloudinary usa un preset unsigned. La app no contiene API secret. `CloudinaryService` valida tamaño y tipos admitidos antes del upload.

Para producción se recomienda:

- Restringir el preset a imágenes y carpetas autorizadas.
- Usar uploads firmados desde backend para PDFs y recursos administrativos.
- Aplicar moderación y antivirus a documentos.

## Riesgos actuales

| Riesgo | Impacto | Recomendación |
|---|---|---|
| Flutter escribe `token_transactions` directamente, pero reglas lo reservan a admin | El flujo puede fallar al desplegar reglas estrictas | Mover tokens al backend |
| `updatePremiumStatus` existe en cliente | Contradice protección de plan | Retirar y usar backend |
| Perfiles legacy permiten escritura amplia al propietario | Puede alterar tokens/racha | Restringir campos o mover mutaciones al backend |
| Preset Cloudinary unsigned | Posible abuso si no está restringido | Firmar uploads sensibles |
| Catálogo mock y Firestore divergen | Inconsistencia operativa | Unificar endpoint |

## Datos sensibles

- No deben versionarse claves privadas de Firebase Admin.
- `.env` móvil contiene identificadores/preset, nunca secretos.
- Los logs no deben exponer tokens, credenciales ni URLs firmadas sensibles.

