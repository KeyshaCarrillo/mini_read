# Flujos del Sistema

## Registro

```mermaid
sequenceDiagram
    actor U as Usuario
    participant App as RegisterPage
    participant Auth as Firebase Auth
    participant DB as Firestore

    U->>App: Correo y contraseña
    App->>Auth: createUserWithEmailAndPassword
    Auth-->>App: UID
    App->>DB: Crea users/{uid}
    App->>App: Navega a onboarding
```

## Login y sesión persistente

```mermaid
sequenceDiagram
    actor U as Usuario
    participant App as LoginPage/AuthGate
    participant Auth as Firebase Auth
    participant DB as Firestore

    U->>App: Credenciales
    App->>Auth: signInWithEmailAndPassword
    Auth-->>App: Sesión
    App->>DB: Carga cuenta, perfiles e historial
    Note over App,Auth: AuthGate escucha authStateChanges
```

## Lectura

```mermaid
sequenceDiagram
    actor U as Lector
    participant H as Home
    participant R as ReadingPage
    participant C as HomeController
    participant D as Firestore

    U->>H: Selecciona libro
    H->>R: Abre Book
    U->>R: Cambia de página
    R->>C: saveReadingProgress
    C->>D: Set history_reading/{profileId-bookId}
```

## Actualización de avatar

```mermaid
sequenceDiagram
    actor U as Usuario
    participant UI as Editar perfil
    participant C as Cloudinary
    participant D as Firestore

    U->>UI: Cámara o galería
    UI->>C: Imagen con publicId único
    C-->>UI: secure_url nueva
    UI->>D: Actualiza photoUrl o avatarUrl
```

## Consulta IA actual

```mermaid
sequenceDiagram
    actor U as Lector
    participant R as ReadingPage
    participant C as HomeController
    participant D as Firestore

    U->>R: Pregunta sobre página/libro
    R->>C: validateAiAccess
    C->>D: Descuenta tokens en perfil
    C->>D: Registra token_transaction
    C-->>R: Respuesta simulada local
    R->>D: Guarda ia_chats
```

La respuesta IA todavía es simulada en `HomeController.mockAiAnswer`; no existe integración con un modelo externo.

