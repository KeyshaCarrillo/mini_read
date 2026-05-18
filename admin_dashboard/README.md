# Mini Read Admin Dashboard

`admin_dashboard` es una aplicación **Flutter Web independiente** para administradores y operadores de Mini Read. No forma parte de la app cliente principal, no reutiliza navegación mobile y no mezcla pantallas de lectura/cliente con flujos administrativos.

## Propósito

El dashboard está orientado a:

- Analítica ejecutiva y operativa.
- Monitoreo de salud de plataforma.
- Métricas de usuarios, lectura y engagement.
- Reportes administrativos.
- Gestión de usuarios y actividad.
- Supervisión de consumo de tokens y señales de riesgo.

## Arquitectura

```text
admin_dashboard/
├── lib/
│   ├── app/                 # Composición raíz de la app y configuración responsive
│   ├── core/                # Config, constantes, responsive, servicios, theme y utils
│   ├── features/            # Módulos funcionales del dashboard admin
│   │   ├── activity/
│   │   ├── analytics/
│   │   ├── dashboard/
│   │   ├── reports/
│   │   ├── settings/
│   │   ├── tokens/
│   │   └── users/
│   ├── routes/              # Definición de rutas y navegación admin
│   ├── shared/              # Widgets, componentes, layouts, animaciones y extensiones
│   └── main.dart            # Entry point Flutter Web
├── assets/                  # Assets exclusivos del dashboard
├── web/                     # Configuración web del proyecto
├── analysis_options.yaml
└── pubspec.yaml
```

## Diseño y UX

La interfaz mantiene el patrón del mock original:

- Sidebar izquierda.
- Topbar superior.
- Cards KPI.
- Gráficas analíticas.
- Paneles de monitoreo.
- Tabla de actividad.

La implementación busca una estética SaaS enterprise inspirada en Stripe, Linear, Vercel, GitHub Enterprise, Supabase, Datadog, Notion Analytics y Clerk:

- Layout compacto y profesional.
- Paleta zinc/slate/indigo.
- Tipografía Inter mediante `google_fonts`.
- Dark mode y light mode.
- Microinteracciones sutiles.
- Componentes reutilizables.
- Sistema de espaciado basado en 8px.
- Estados de carga con skeletons.

## Dependencias principales

- `flutter_riverpod`: estado y preparación para data flows escalables.
- `responsive_framework`: breakpoints web para tablet, laptop y desktop.
- `fl_chart`: gráficas reales para KPIs y analytics.
- `data_table_2`: tabla enterprise con header fijo y layout avanzado.
- `flutter_animate`: animaciones sutiles de entrada.
- `google_fonts`: tipografía Inter.

## Ejecutar en desarrollo

```bash
cd admin_dashboard
flutter pub get
flutter run -d chrome
```

## Análisis y pruebas

```bash
cd admin_dashboard
flutter analyze
flutter test
```

## Build web

```bash
cd admin_dashboard
flutter build web --release
```

## Notas importantes

- Esta app debe permanecer separada de la aplicación principal de Mini Read.
- No se deben importar pantallas de lectura, biblioteca o navegación mobile desde la app cliente.
- Los flujos de administrador deben vivir dentro de `admin_dashboard/lib/features`.
- Los componentes compartidos del dashboard deben vivir en `admin_dashboard/lib/shared`.
- Evitar agregar archivos binarios si el entorno de revisión/importación no los admite.
