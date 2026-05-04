# Plan de trabajo — StrengthLabs

**Autor de este documento**: Oscar Eduardo
**Fecha**: 2026-05-04
**Estado**: vivo — actualizar a medida que avance el proyecto

Este documento es la fuente de verdad para retomar el proyecto en cualquier momento.
Si algo en el código contradice lo que dice este documento, gana el código y este
documento se actualiza.

---

## 1. Contexto del proyecto

### 1.1 Qué es StrengthLabs

Aplicación móvil multiplataforma (iOS y Android) para registro y análisis de
entrenamientos de fuerza, con cálculo científico de fatiga, riesgo de lesión y
periodización basada en bloques (Issurin 2008). El usuario registra sesiones con
ejercicios, series, peso y RPE; la app calcula métricas avanzadas
(ATL, CTL, TSB, ACWR, monotonía, strain, ramp rate, readiness) y genera planes
semanales adaptados al estado del atleta.

### 1.2 Cómo llegó a mis manos

El proyecto fue íntegramente construido por **Yeisen Kenneth López Reyes**
(GitHub: `YeisenK`, también firmaba como "void" en el frontend). Yeisen escribió:

- Frontend Flutter completo (~8000 líneas Dart)
- Backend Java/Spring Boot 4 con Clean Architecture
- Compute engine Python/FastAPI con modelos científicos
- Documentación técnica en LaTeX (PDFs)

Yeisen ya no participa en el proyecto. Yo (Oscar) quedé como único desarrollador
y tengo autonomía total para tomar decisiones de diseño, refactorizar y completar
lo que falta.

### 1.3 Repositorios y carpetas

```
~/StrengthLabs/                          ← Frontend Flutter (este repo)
├── lib/                                  ← Código Dart (BLoC + go_router + Dio)
├── android/, ios/, linux/, macos/, web/, windows/
├── documentacion/                        ← PDFs y este PLAN.md
├── pubspec.yaml
└── README.md

~/StrengthLabsBackend/                   ← Backend Java + compute engine (repo aparte)
├── src/main/java/com/strengthlabs/      ← Spring Boot 4 + JPA + Security
│   ├── domain/                           ← Entidades puras + interfaces
│   ├── application/                      ← UseCases + DTOs + Ports
│   ├── infrastructure/                   ← JPA, JWT, RBAC, Python adapter
│   └── presentation/                     ← Controllers REST
├── recursos/                             ← Compute engine Python/FastAPI
│   ├── api/                              ← Routers FastAPI
│   ├── domain/                           ← Modelos científicos (TRIMP, EWMA, etc.)
│   └── tests/
├── docker/
│   ├── docker-compose.yml                ← Postgres + Redis + compute-engine
│   ├── Dockerfile.api
│   └── Dockerfile.compute
├── schema.sql                            ← Esquema actual (será reemplazado)
└── pom.xml
```

### 1.4 Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3.10 · BLoC 8.x · go_router 13.x · Dio 5.x |
| Almacenamiento local | flutter_secure_storage (tokens) |
| Backend API | Java 21 · Spring Boot 4.0.3 · Spring Security · Spring Data JPA |
| ORM / BD | Hibernate 6 · PostgreSQL 16 |
| Cache | Redis 7 |
| Auth | JWT HS256 (JJWT 0.12) · BCrypt · Google Sign-In (pendiente) |
| Compute engine | Python 3.12 · FastAPI · NumPy · SciPy |
| Contenedores | Docker · Docker Compose |
| Doc API | SpringDoc OpenAPI 2.x (Swagger UI en `/swagger-ui.html`) |
| Exportación | Apache POI (XLSX) en backend · `excel` + `share_plus` en frontend |

### 1.5 Servicios y puertos en local

| Servicio | Host | Puerto |
|---|---|---|
| Backend API (Spring Boot) | localhost | 8000 |
| Compute engine (FastAPI) | localhost | 8001 |
| PostgreSQL | localhost | 5432 |
| Redis | localhost | 6379 |
| Frontend (emulador Android) | usa `http://10.0.2.2:8000` para hablar al backend |

---

## 2. Estado real de cada componente

### 2.1 Frontend (`~/StrengthLabs/`)

**Lo que funciona:**

- 5 tabs navegables (Workouts, Routines, Fatigue, Plan, Export) con `go_router`
- Auth flow completo con BLoC (`AuthCubit` + `AuthRepository`)
- Modo demo (`example@example.com / example`) que sirve mock data sin backend
- Pantallas implementadas: Login, Register, WorkoutList, WorkoutDetail,
  ActiveWorkout, Routines, RoutineDetail, FatigueDashboard, Plan, Export
- Repositorios listos para conectarse al backend real (Dio + interceptor JWT
  con refresh automático)
- Generación local de planes semanales en Dart desde métricas ya descargadas
- Exportación CSV/XLSX en dispositivo

**Lo que NO funciona o está incompleto:**

- Filtros del historial (por fecha y muscle group) — prometidos en doc, no
  implementados
- Búsqueda en el selector de ejercicios — verificar
- Confirmación al borrar workout — verificar
- Internacionalización: toda la UI en inglés, sin soporte i18n
- Google Sign-In: dependencia agregada, falta `google-services.json` y
  `serverClientId`

**Código muerto detectado:**

- `lib/core/storage/workout_local_storage.dart` — nadie lo usa de verdad
- `ComputeRepository.computeMetrics()` — no se invoca desde ningún lado
- Los métodos `isFirstLaunch()` / `markSeeded()` — nadie los llama

**Configuración pendiente:**

- `applicationId` sigue siendo `com.example.strengthlabs_beta`
- Signing key release usa la debug key
- No hay iconos ni splash propios (usa los default de Flutter)
- `.vscode/settings.json` apunta a una ruta vieja (`/home/void/`)
- Credenciales demo precargadas en `LoginPage` (`example@example.com`)

### 2.2 Backend Java (`~/StrengthLabsBackend/`)

**Lo que funciona:**

- Clean Architecture con cuatro capas bien separadas
- `SecurityConfig` con JWT + BCrypt + CORS abierto
- `JwtTokenProvider` con tests unitarios
- `RbacFilter` para roles (USER / TRAINER / ADMIN)
- `GlobalExceptionHandler` que oculta detalles internos al cliente
- `PythonComputeAdapter` que llama al compute engine vía HTTP
- Docker Compose que levanta Postgres + Redis + compute-engine
- `schema.sql` aplicable a Postgres

**Lo que NO funciona o está mal alineado con el frontend:**

- **Modelo de datos plano**: `training_sessions` tiene un solo `muscle_group`,
  `weight_kg` y `rpe` por sesión. El frontend espera jerarquía workout →
  exercises → sets con peso/reps/RPE individuales por set
- **No existen tablas**: `exercises`, `routines`, `routine_days`,
  `routine_exercises`, `workout_exercises`, `workout_sets`
- **Prefijo de URL inconsistente**: `AuthController` usa `/auth/*` pero
  `SessionController` usa `/api/v1/sessions`. El frontend espera todo bare
- **Endpoints faltantes**: `/auth/google`, `/auth/refresh` (verificar),
  `/exercises`, `/routines`, `/export/csv`, `/export/xlsx` (verificar)
- **Shape de `/fatigue/summary`** no coincide con lo que parsea el frontend

**Detalles a verificar al levantarlo:**

- `JwtTokenProvider` usa **HS256** (no RS256 como dice el README)
- `username` es obligatorio en tabla `users` pero el frontend solo manda email
- Existe constraint `UNIQUE (user_id, metric_date)` en `training_metrics` que
  puede dar conflictos al recalcular el mismo día

### 2.3 Compute engine (`~/StrengthLabsBackend/recursos/`)

**Lo que funciona:**

- Tres routers: `/compute/fatigue`, `/compute/risk`, `/compute/plan`
- Modelos en `domain/`: `fatigue_model.py`, `risk_model.py`,
  `periodization_model.py`
- Tests en `tests/`
- Endpoint `/health`

**Status:** asumido funcional, hay que verificar levantándolo.

### 2.4 Documentación PDF (`documentacion/`)

| Archivo | Estado |
|---|---|
| `Doc General.pdf` (v1.0, 8-abr-2026) | Coincide con backend Java actual. Mantener |
| `Arquitectura.pdf` (v0.2.0, 7-abr-2026) | Describe versión Python anterior, contradice el código real. Borrar o marcar como deprecated |
| `Arquitectura(deprecated).pdf` | Ya marcada deprecated. Borrar |

---

## 3. Decisiones arquitectónicas tomadas

### 3.1 Decisión principal: Camino 2 — extender backend Java

**Contexto:** existe un gap grande entre frontend (modelo jerárquico
completo) y backend (modelo plano simplificado). Hay tres caminos posibles:

1. Adaptar frontend al backend (perder ~40% de la UX)
2. **Extender backend para que coincida con frontend** ← elegido
3. Tirar el backend Java y empezar uno nuevo en otro stack

**Razones de la elección:**

- El backend Java tiene Clean Architecture sólida, JWT/Security/Redis/JPA
  ya configurados — sería un desperdicio tirarlo
- El frontend está muy completo y su modelo jerárquico es el correcto para
  un usuario real de gym (un workout tiene N ejercicios, cada uno con M sets
  distintos)
- Spring Boot facilita agregar entidades sin romper lo existente
- Aunque mi Java/Spring no es nativo, manejo lo suficiente para extender
  controllers y entidades

### 3.2 Decisiones secundarias

- **Modo offline**: descartado para v1.0. El `WorkoutLocalStorage` y
  `ComputeRepository.computeMetrics()` se borran. Si querés offline real,
  se planifica para v1.1 con un cache HTTP limpio (ej: `dio_cache_interceptor`)
- **Plan se genera local en Dart**: queda como está. El compute engine NO se
  llama desde Flutter; solo desde el backend Java internamente
- **i18n**: español como único idioma para v1.0. Si después se quiere
  bilingüe, se agrega `flutter_localizations` y `.arb`
- **Doc**: actualizar `Doc General.pdf` cuando termine cada fase. Borrar
  `Arquitectura.pdf` y `Arquitectura(deprecated).pdf`
- **Branch strategy**: trabajar en `main`. Como soy único dev no necesito
  PRs. Branches solo para features grandes que tarden días
- **Repos separados**: mantener frontend y backend en repos distintos.
  Tener todo en monorepo no aporta nada cuando hay un solo dev

### 3.3 Convenciones a respetar

- **URLs sin prefijo `/api/v1/`** — el frontend lo asume así. Hay que
  uniformar el backend
- **JSON en snake_case**: `access_token`, `refresh_token`, `weekly_volume`,
  `is_overtraining`. El frontend ya parsea así
- **Fechas en ISO 8601 UTC**: `2026-04-08T10:00:00Z`
- **IDs como UUID v4** generados por Postgres con `gen_random_uuid()`

---

## 4. Plan de trabajo por fases

Estimación total: **4-5 semanas full-time** o **8-10 part-time**.

### Fase 0 — Setup y verificación (½ día)

**Objetivo**: confirmar que ambos componentes arrancan localmente antes de
tocar nada.

**Tareas:**

1. Levantar infraestructura Docker:
   ```bash
   cd ~/StrengthLabsBackend
   cp .env.example .env
   # editar .env y agregar DB_PASSWORD=changeme
   docker compose -f docker/docker-compose.yml up postgres redis -d
   ```
2. Aplicar `schema.sql` actual a Postgres (provisional, lo reemplazamos en
   Fase 2)
3. Arrancar backend Java:
   ```bash
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
   ```
4. Verificar que `http://localhost:8000/swagger-ui.html` carga
5. Arrancar compute engine:
   ```bash
   cd recursos
   pip install -r requirements.txt
   uvicorn api.main:app --port 8001 --reload
   ```
6. Verificar `http://localhost:8001/health` responde `{"status": "ok"}`
7. Arrancar frontend:
   ```bash
   cd ~/StrengthLabs
   flutter pub get
   flutter run
   ```
8. Loguearse en modo demo y navegar las 5 tabs

**Limpieza inicial (mientras tanto):**

- Borrar `~/StrengthLabs/backend/` (skeleton Python obsoleto)
- Borrar `~/StrengthLabs/.vscode/settings.json` (ruta vieja `/home/void/`)
- Borrar `documentacion/Arquitectura(deprecated).pdf`

**Hito:** screenshot del frontend andando + Swagger UI cargando + curl al
compute engine respondiendo.

---

### Fase 1 — Mapeo concreto del contrato API (1 día)

**Objetivo**: tabla maestra que dice qué hacer en cada endpoint.

**Entregable**: archivo `documentacion/api-contract.md` con esta estructura:

```markdown
# Contrato API frontend ↔ backend

## Convenciones globales
- URLs sin prefijo /api/v1/
- JSON snake_case
- Auth: Bearer token en header Authorization

## Endpoints

| Frontend espera | Backend tiene | Estado | Acción |
|---|---|---|---|
| POST /auth/login | POST /auth/login | ✓ | verificar shape |
| POST /auth/register | POST /auth/register | ✓ | verificar shape |
| POST /auth/refresh | ? | ? | verificar |
| GET /auth/me | ? | ? | verificar |
| POST /auth/google | ❌ | falta | crear |
| GET /workouts | GET /api/v1/sessions | ⚠ | refactor: nombre + shape |
| POST /workouts | POST /api/v1/sessions | ⚠ | refactor: jerarquía |
| ...etc...
```

Para cada endpoint con ⚠ o ❌, anotar el shape exacto del request/response
que espera el frontend (mirar los repositorios en
`lib/features/*/data/*_repository.dart`).

**Hito**: documento que da el orden exacto de trabajo para Fases 2-6.

---

### Fase 2 — Schema nuevo de BD (2 días)

**Objetivo**: tablas alineadas con el modelo del frontend.

**Decisión**: como el proyecto está en MVP y la BD está vacía, se hace
**reset completo** del schema en vez de migración incremental.

**Tareas:**

1. Reescribir `schema.sql` con el modelo nuevo:

   ```sql
   -- Mantener
   users
   training_metrics  -- snapshots de cálculos diarios

   -- Borrar
   training_sessions  -- modelo plano viejo

   -- Crear
   exercises (
     id UUID PK,
     name VARCHAR NOT NULL,
     muscle_group muscle_group NOT NULL,
     is_custom BOOLEAN DEFAULT false,
     created_by UUID REFERENCES users(id),
     created_at TIMESTAMPTZ DEFAULT NOW()
   )

   workouts (
     id UUID PK,
     user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
     name VARCHAR NOT NULL,
     date TIMESTAMPTZ NOT NULL,
     duration_seconds INTEGER,
     notes TEXT,
     created_at TIMESTAMPTZ DEFAULT NOW()
   )

   workout_exercises (
     id UUID PK,
     workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
     exercise_id UUID NOT NULL REFERENCES exercises(id),
     order_index INTEGER NOT NULL
   )

   workout_sets (
     id UUID PK,
     workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
     weight NUMERIC(6,2) NOT NULL CHECK (weight >= 0),
     reps SMALLINT NOT NULL CHECK (reps >= 0),
     rpe NUMERIC(3,1) CHECK (rpe BETWEEN 1 AND 10),
     order_index INTEGER NOT NULL
   )

   routines (
     id VARCHAR(64) PK,  -- ej: 'r-beg-strength'
     name VARCHAR NOT NULL,
     level VARCHAR NOT NULL,  -- beginner / intermediate / advanced
     goal VARCHAR NOT NULL,   -- strength / hypertrophy / endurance / general_fitness
     days_per_week SMALLINT NOT NULL,
     description TEXT
   )

   routine_days (
     id UUID PK,
     routine_id VARCHAR(64) NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
     name VARCHAR NOT NULL,
     order_index INTEGER NOT NULL
   )

   routine_exercises (
     id UUID PK,
     day_id UUID NOT NULL REFERENCES routine_days(id) ON DELETE CASCADE,
     exercise_id UUID NOT NULL REFERENCES exercises(id),
     sets SMALLINT NOT NULL,
     reps_scheme VARCHAR(32) NOT NULL,  -- ej: '5', '8-12', '5/3/1+'
     notes TEXT,
     order_index INTEGER NOT NULL
   )
   ```

2. Agregar **Flyway** al `pom.xml` para versionar migraciones desde
   ahora — no más `schema.sql` manual:
   ```xml
   <dependency>
     <groupId>org.flywaydb</groupId>
     <artifactId>flyway-core</artifactId>
   </dependency>
   ```
3. Mover el schema nuevo a `src/main/resources/db/migration/V1__initial_schema.sql`
4. Crear las JPA entities en `infrastructure/persistence/jpa/`:
   - `ExerciseJpaEntity`, `WorkoutJpaEntity`, `WorkoutExerciseJpaEntity`,
     `WorkoutSetJpaEntity`, `RoutineJpaEntity`, `RoutineDayJpaEntity`,
     `RoutineExerciseJpaEntity`
5. Crear `JpaRepository` interfaces correspondientes
6. Crear los `RepositoryAdapter` que implementan los puertos del dominio

**Hito**: `./mvnw test` pasa. Postgres tiene las 8 tablas finales. Inserts
y selects manuales con `psql` funcionan.

---

### Fase 3 — Auth alineado (1-2 días)

**Objetivo**: el frontend se loguea contra el backend real (sin modo demo).

**Tareas:**

1. Verificar que `JwtTokenProvider` usa **HS256**. Si usa RS256, cambiar
   a HS256 (el frontend asume HS256 al decodificar el JWT)
2. Verificar shape de respuestas:
   - `POST /auth/register` y `POST /auth/login` deben devolver
     `{"access_token": "...", "refresh_token": "..."}`
   - `GET /auth/me` debe devolver `{"id": "...", "name": "...", "email": "..."}`
     (sin `role`, sin `username`)
   - `POST /auth/refresh` recibe `{"refresh_token": "..."}` y devuelve el
     mismo shape que login
3. Resolver el conflicto de `username`:
   - El backend tiene `username` obligatorio y único en `users`
   - El frontend solo manda email
   - **Solución**: derivar `username` automáticamente del email (parte
     antes del `@`) en el `RegisterUseCase`. Si choca con un usuario
     existente, agregar sufijo numérico
4. Implementar `POST /auth/google`:
   - Recibir `{"id_token": "..."}` desde el frontend
   - Verificar contra Google con la librería `google-api-client` (Java)
   - Si el email no existe, crear user automáticamente
   - Devolver el mismo `{access_token, refresh_token}` que login normal

**Hito**: en el frontend creás un usuario nuevo con `/register`, el user
queda en Postgres, te logueás con `/login`, abrís la app y te dirige a
la pantalla de workouts (vacía).

---

### Fase 4 — Workouts CRUD + Exercises (3-4 días)

Es la fase más grande. Es el corazón del refactor.

**4.1 ExerciseController (1 día)**

- Endpoints:
  - `GET /exercises` → lista global + custom del usuario autenticado
  - `POST /exercises` → crear ejercicio custom
- Refactor `ExerciseDataSeeder.java` para insertar los **62 ejercicios
  globales** del Doc General Anexo A si la tabla está vacía (idempotente)

**4.2 WorkoutController (2 días)**

- Borrar `SessionController` viejo
- Crear `WorkoutController` con `@RequestMapping("/workouts")` (sin
  `/api/v1`)
- Endpoints:
  - `GET /workouts` → `{"items": [workout]}` con jerarquía completa
  - `POST /workouts` → recibe el JSON jerárquico que manda el frontend
  - `GET /workouts/{id}` → detalle con exercises + sets anidados
  - `PUT /workouts/{id}` → actualiza solo `name` y/o `notes`
  - `DELETE /workouts/{id}` → cascade
- Shape exacto del request en POST: ver `WorkoutRepository.createWorkout()`
  en `lib/features/workouts/data/workout_repository.dart` línea ~45

**4.3 RegisterSessionUseCase → CreateWorkoutUseCase**

- Renombrar y reescribir para procesar la jerarquía workout → exercises → sets
- Después de guardar, disparar el cálculo de métricas en background
  (publicar evento o llamar `CalculateFatigueUseCase` directo)

**4.4 Mappers DTO ↔ Entity ↔ Domain**

Mantener Clean Architecture: el controller recibe DTOs, los pasa al
UseCase como entidades de dominio, el adapter las convierte a JPA entities
para persistir.

**Hito**: en el frontend creás un workout con 3 ejercicios y 4 sets cada
uno → se guarda en Postgres → aparece en la lista → lo abrís → lo borrás.

---

### Fase 5 — Fatigue + Compute Engine (3 días)

**Objetivo**: el dashboard de fatiga muestra datos reales calculados.

**5.1 Verificar compute engine (½ día)**

- Levantar `recursos/api/main.py` en `:8001`
- Probar `POST /compute/fatigue` con curl y un payload de ejemplo
- Verificar que `PythonComputeAdapter` en backend Java lo llama bien

**5.2 Refactor FatigueController (1.5 días)**

- `GET /fatigue/summary` debe devolver el shape exacto que parsea
  `FatigueRepository.getSummary()` en frontend (ver
  `lib/features/fatigue/data/fatigue_repository.dart` línea ~14)
- `GET /fatigue/weekly` → volumen semanal por grupo muscular
- Internamente:
  1. Lee últimos 90 días de workouts del usuario
  2. Convierte cada workout a `{date, duration_minutes, rpe}` con
     `load = duration_min × avg_rpe` (Foster session-RPE)
  3. Llama a `POST /compute/fatigue` y `POST /compute/risk` vía
     `PythonComputeAdapter`
  4. Calcula `weekly_volume` por grupo muscular en el backend (sumar
     volumen = peso × reps por cada set, agrupado por muscle_group)
  5. Genera `trend` con los últimos 14 días
  6. Combina todo y devuelve

**5.3 Cache en `training_metrics` (1 día)**

- Después de cada cálculo, guardar snapshot en `training_metrics`
- En el siguiente request del mismo día, devolver el snapshot cacheado
  (evitar recalcular)
- Solucionar el constraint `UNIQUE (user_id, metric_date)`: usar
  `INSERT ... ON CONFLICT DO UPDATE` (upsert)

**Hito**: dashboard de fatiga en el frontend muestra readiness score real,
métricas (ATL/CTL/TSB/ACWR), gráfico de tendencia y recomendaciones.

---

### Fase 6 — Routines + Export (2 días)

**6.1 RoutineController (1 día)**

- Endpoints:
  - `GET /routines?level=beginner|intermediate|advanced`
  - `GET /routines/{id}`
- Seeder con las **5 rutinas** del Doc General Anexo B:
  - `r-beg-strength` — 3-Day Beginner Strength
  - `r-int-hyp` — 4-Day Upper/Lower Hypertrophy
  - `r-adv-str` — 5-Day Advanced Powerbuilding
  - `r-beg-gen` — 3-Day Beginner General Fitness
  - `r-int-end` — 4-Day Intermediate Endurance + Strength

**6.2 ExportController (1 día)**

- Endpoints:
  - `GET /export/xlsx` con Apache POI
  - `GET /export/csv` con OpenCSV o manual
- Columnas: Date, Workout, Exercise, Muscle Group, Set #, Weight (kg),
  Reps, RPE, Volume (kg)
- Una fila por cada set
- Ordenado por fecha descendente
- **Nota**: el frontend ya tiene su propio `ExportService` que genera los
  archivos en el dispositivo y los comparte. Los endpoints del backend
  son redundantes para uso móvil, pero útiles si después se hace una web

**Hito**: rutinas se ven en la app, podés iniciar una rutina como template
de active workout, podés exportar tu historial a XLSX y compartirlo por
WhatsApp.

---

### Fase 7 — Frontend cleanup + pre-release (3-5 días)

Estas tareas se pueden hacer **en paralelo** durante todas las fases
anteriores cuando haya tiempo muerto esperando endpoints del backend.

**7.1 Cleanup técnico (1 día)**

- Borrar código muerto:
  - `lib/core/storage/workout_local_storage.dart`
  - `ComputeRepository.computeMetrics()` (mantener solo `computePlan` o
    renombrar la clase a `PlanBuilder`)
  - Posiblemente fusionar `PlanRepository` con `PlanBuilder`
- Centralizar `_parseMuscleGroup` (está duplicado en 3 archivos):
  moverlo como método estático en `MuscleGroup` enum
- Quitar credenciales demo precargadas en `LoginPage:20-21` (o esconder
  detrás de un flag debug)
- Decidir qué hacer con el modo demo: borrarlo o dejarlo como fallback de
  presentación
- Quitar dependencia `shared_preferences` del `pubspec.yaml` si se borra
  `WorkoutLocalStorage`

**7.2 i18n a español (1-2 días)**

- Agregar `flutter_localizations` y `intl` al `pubspec.yaml`
- Crear `lib/l10n/app_es.arb` con todas las strings
- Convertir `AppStrings` a `AppLocalizations` generadas
- Configurar `MaterialApp.router` con `localizationsDelegates` y
  `supportedLocales: [Locale('es')]`

**7.3 Filtros y mejoras UI (1 día)**

- Filtros del historial por fecha (DateRange) y muscle group (chip selector)
  en `WorkoutListPage`
- Búsqueda en exercise picker de `ActiveWorkoutPage`
- Confirmación con `AlertDialog` al borrar workout en `WorkoutDetailPage`

**7.4 Pre-release config (1 día)**

- Cambiar `applicationId` en `android/app/build.gradle.kts` (ej:
  `com.strengthlabs.app`)
- Cambiar `namespace` y `MainActivity` package en consecuencia
- Crear iconos con `flutter_launcher_icons`:
  - `pubspec.yaml`: agregar `flutter_launcher_icons` con paths a PNGs
  - Generar con `flutter pub run flutter_launcher_icons:main`
- Crear splash screen con `flutter_native_splash`
- Configurar Google Sign-In real:
  1. Crear proyecto en Google Cloud Console
  2. Habilitar Google Sign-In API
  3. Crear OAuth 2.0 client IDs (Android + iOS + Web)
  4. Descargar `google-services.json` y poner en `android/app/`
  5. Pasar `serverClientId` al constructor `GoogleSignIn(serverClientId: ...)`
- Crear keystore release:
  ```bash
  keytool -genkey -v -keystore ~/strengthlabs-release.jks \
          -keyalg RSA -keysize 2048 -validity 10000 -alias strengthlabs
  ```
- Configurar signing en `android/app/build.gradle.kts`:
  ```kotlin
  signingConfigs {
      create("release") {
          storeFile = file(System.getenv("KEYSTORE_PATH"))
          storePassword = System.getenv("KEYSTORE_PASSWORD")
          keyAlias = "strengthlabs"
          keyPassword = System.getenv("KEY_PASSWORD")
      }
  }
  buildTypes {
      release {
          signingConfig = signingConfigs.getByName("release")
      }
  }
  ```

**Hito**: APK release firmado funcionando, app traducida al español, lista
para subir a Google Play (canal interno o cerrado).

---

## 5. Resumen de orden y dependencias

| Fase | Duración | Bloquea | Paralelizable con |
|---|---|---|---|
| 0 — Setup | ½ día | Todo | — |
| 1 — Mapeo API | 1 día | Backend (2-6) | 7.1 cleanup |
| 2 — Schema BD | 2 días | 3, 4 | 7.1, 7.2 |
| 3 — Auth | 1-2 días | 4 | 7.1, 7.2 |
| 4 — Workouts/Exercises | 3-4 días | 5 | 7.2, 7.3 |
| 5 — Fatigue/Compute | 3 días | — | 7.3 |
| 6 — Routines/Export | 2 días | — | 7.4 |
| 7 — Frontend cleanup | 3-5 días | Release | Todas |

---

## 6. Trampas conocidas que voy a encontrar

### 6.1 Prefijo `/api/v1/` inconsistente en el backend

Algunos controllers tienen `@RequestMapping("/api/v1/sessions")` y otros
solo `@RequestMapping("/auth")`. El frontend usa bare paths sin prefijo.

**Solución elegida**: quitar `/api/v1/` de todos los controllers. No usar
`server.servlet.context-path`. Mantener simple.

### 6.2 `username` obligatorio en tabla `users`

El frontend solo manda email. El backend requiere `username` único.

**Solución**: derivar `username = email.split('@')[0]` en
`RegisterUseCase`. Si choca con uno existente, sufijar con número
incremental (`oscar`, `oscar1`, `oscar2`...).

### 6.3 `UNIQUE (user_id, metric_date)` en `training_metrics`

Si calculo métricas dos veces el mismo día, se cae con conflicto único.

**Solución**: usar UPSERT (`INSERT ... ON CONFLICT (user_id, metric_date)
DO UPDATE`) en el adapter de persistencia.

### 6.4 Roles USER/TRAINER/ADMIN del backend

El backend tiene RBAC implementado pero el frontend no maneja roles. Para
v1.0 solo se usa `USER`. Más adelante (v2.0 panel admin) se aprovecha.

**Solución v1.0**: hardcodear `role = USER` en el `RegisterUseCase`. El
RBAC sigue activo para el endpoint `/api/v1/admin/*` pero ningún user
llega ahí.

### 6.5 JWT HS256 vs RS256

El README del backend dice "JWT RS256 + OAuth 2.0" pero el código
probablemente usa HS256 (más simple, suficiente para MVP). El frontend
asume HS256.

**Solución**: verificar `JwtTokenProvider.java` y forzar HS256.

### 6.6 Compute engine ignora `training_metrics`

El compute engine es stateless: no lee BD. Solo procesa lo que le manda
el backend Java por POST. El cache vive en `training_metrics` del backend.

**Solución**: cuando refactor `FatigueController`, asegurarse de que el
backend lee de `training_metrics` antes de invocar al compute engine si
ya hay un snapshot del día.

### 6.7 Mapeo de muscle groups incompleto en frontend

El backend usa 13 muscle groups (CHEST, BACK, SHOULDERS, BICEPS, TRICEPS,
FOREARMS, QUADS, HAMSTRINGS, GLUTES, CALVES, CORE, FULL_BODY, OTHER). El
frontend solo tiene 6 en el enum (chest, back, legs, shoulders, arms,
core). El parseo agrupa los del backend en los del frontend.

**Solución**: mantener el mapeo actual en `_parseMuscleGroup`,
centralizado en `MuscleGroup` enum. Para v2.0 se puede expandir el enum
del frontend.

---

## 7. Glosario rápido

| Término | Significado |
|---|---|
| **ATL** | Acute Training Load — fatiga aguda (EWMA 7 días) |
| **CTL** | Chronic Training Load — forma física crónica (EWMA 42 días) |
| **TSB** | Training Stress Balance = CTL − ATL. Positivo = fresco |
| **ACWR** | Acute:Chronic Workload Ratio = ATL / CTL. Zona dulce 0.8–1.3 |
| **EWMA** | Exponentially Weighted Moving Average |
| **RPE** | Rate of Perceived Exertion (escala 1–10) |
| **TRIMP** | Training Impulse — modelo de carga de Banister |
| **Readiness** | Score 0–100 compuesto de ACWR, TSB, monotonía y ramp rate |
| **Microciclo** | Semana de entrenamiento con tipo (loading, deload, peak, etc.) |
| **Issurin 2008** | Periodización por bloques (referencia científica) |

---

## 8. Próximo paso concreto

**Hoy**: Fase 0 — verificar que todo arranca.

Checklist:
- [ ] Docker corriendo (`docker --version`, `docker compose --version`)
- [ ] JDK 21 instalado (`java --version`)
- [ ] Maven (vía `mvnw` no hace falta global)
- [ ] Python 3.12 (`python3 --version`)
- [ ] Flutter SDK (`flutter doctor`)
- [ ] Postgres y Redis arriba via docker-compose
- [ ] Backend Java arranca y `/swagger-ui.html` carga
- [ ] Compute engine arranca y `/health` responde
- [ ] Frontend arranca en emulador y entra al modo demo

Si algo falla, anotarlo en este documento y resolverlo antes de seguir.

---

## Cambios a este documento

| Fecha | Cambio |
|---|---|
| 2026-05-04 | Versión inicial |
