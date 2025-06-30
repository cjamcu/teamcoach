# TeamCoach

TeamCoach es una aplicación móvil para la gestión de equipos de softball que permite el registro de rosters, seguimiento de jugadas y generación de estadísticas. La aplicación funciona sin conexión y se sincroniza automáticamente cuando hay internet disponible.

## 🚀 Estado del Desarrollo

### ✅ Fase 1: Configuración Inicial e Infraestructura Core (Completada)

#### Tareas Completadas:

1. **Configuración del Proyecto**
   - ✅ Proyecto Flutter inicializado con estructura de paquetes adecuada
   - ✅ SDK de Appwrite configurado con soporte offline nativo
   - ✅ Tema shadcn-ui configurado
   - ✅ Signals implementado para gestión de estado
   - ✅ Modelos base e interfaces creados

2. **Servicios Core**
   - ✅ Inyección de dependencias configurada con GetIt
   - ✅ Servicio de Appwrite con autenticación básica
   - ✅ Modo offline configurado usando las capacidades nativas de Appwrite

3. **Componentes UI Base**
   - ✅ Tema shadcn-ui configurado con esquemas de color personalizables
   - ✅ Widgets reutilizables creados (botones, tarjetas)
   - ✅ Estructura de navegación implementada con go_router
   - ✅ Esquema de colores y tipografía de la aplicación

### ✅ Fase 2: Gestión de Roster (Completada)

#### Tareas Completadas:

1. **Operaciones CRUD de Jugadores**
   - ✅ Servicio de jugadores con estado reactivo usando Signals
   - ✅ Crear nuevo jugador con validación de formularios
   - ✅ Editar información del jugador
   - ✅ Eliminar jugador con confirmación
   - ✅ Sincronización automática con Appwrite

2. **Diseño UI/UX**
   - ✅ Tarjetas de jugador con avatar, número y posiciones
   - ✅ Formulario completo con selección de posiciones múltiples
   - ✅ Selector de lado de bateo/lanzamiento con iconos
   - ✅ Estados vacíos ilustrativos
   - ✅ Animaciones y transiciones suaves

3. **Búsqueda y Filtrado**
   - ✅ Búsqueda en tiempo real por nombre, número o posición
   - ✅ Filtrado reactivo con Signals
   - ✅ Indicador de resultados de búsqueda

4. **Acciones Masivas**
   - ✅ Modo de selección múltiple
   - ✅ Seleccionar/deseleccionar todos
   - ✅ Activar/desactivar múltiples jugadores
   - ✅ Eliminar múltiples jugadores con confirmación
   - ✅ Contador de elementos seleccionados

#### Nuevos Archivos Creados:
```
lib/features/roster/
├── services/
│   └── player_service.dart          # Servicio con estado reactivo
├── screens/
│   ├── roster_screen.dart          # Pantalla principal actualizada
│   └── player_form_screen.dart     # Formulario crear/editar
└── widgets/
    ├── position_selector.dart      # Selector de posiciones
    └── side_selector.dart          # Selector de lado bateo/lanzamiento
```

#### Estructura del Proyecto:
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── routes/
│   │   └── app_router.dart
│   └── services/
│       ├── appwrite_service.dart
│       └── service_locator.dart
├── features/
│   ├── auth/
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── roster/
│   │   └── screens/
│   │       └── roster_screen.dart
│   ├── games/
│   │   └── screens/
│   │       └── games_list_screen.dart
│   └── stats/
│       └── screens/
│           └── team_stats_screen.dart
└── shared/
    ├── widgets/
    │   ├── main_scaffold.dart
    │   ├── app_button.dart
    │   └── player_card.dart
    └── models/
        ├── team.dart
        └── player.dart
```

## 🛠️ Stack Tecnológico

- **Framework**: Flutter (iOS + Android)
- **Backend/Base de datos**: Appwrite (local + sincronización remota)
- **Gestión de estado**: Signals (pub.dev/packages/signals)
- **Biblioteca UI**: shadcn_ui
- **Navegación**: go_router
- **Inyección de dependencias**: GetIt

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  appwrite: ^13.0.0
  signals: ^5.5.0
  shadcn_ui: ^0.27.3
  lucide_icons_flutter: ^3.0.0
  get_it: ^8.0.2
  go_router: ^14.7.1
  uuid: ^4.5.1
  intl: ^0.20.2
  collection: ^1.19.0
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  shared_preferences: ^2.3.4
```

## 🏃‍♂️ Cómo ejecutar

1. Clona el repositorio
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Configura tu proyecto de Appwrite:
   - Crea un proyecto en [Appwrite Cloud](https://cloud.appwrite.io)
   - Reemplaza `YOUR_PROJECT_ID` en `lib/core/constants/app_constants.dart` con tu ID de proyecto
   - Crea la base de datos y colecciones según el esquema definido en `docs/development_plan.md`

4. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## 📋 Próximas Fases

### Fase 3: Creación y Control de Juegos (Por hacer)
- Gestión de juegos
- Constructor de alineación
- Asignación de posiciones defensivas

### Fase 4: Seguimiento de Jugadas
- Gestión en juego
- Registro jugada por jugada
- Sustituciones de jugadores

### Fase 5: Estadísticas y Análisis
- Generación de estadísticas
- Visualizaciones y gráficos
- Funcionalidad de exportación

## 🤝 Contribuir

Este proyecto está en desarrollo activo. Si deseas contribuir, por favor abre un issue o envía un pull request.

## 📄 Licencia

Este proyecto está bajo la licencia MIT.
