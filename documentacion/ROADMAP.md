# Roadmap detallado — StrengthLabs

Este documento es el cronograma día por día de todo lo que vamos a hacer
hasta tener la app lista para release. Cada día tiene tareas concretas
con archivos, comandos y un hito verificable.

Para el plan macro y decisiones arquitectónicas: ver `PLAN.md`.
Para el estado actual y próximo paso inmediato: ver `CHECKLIST.md`.

---

## Resumen ejecutivo

| Métrica | Valor |
|---|---|
| Días totales estimados | 17 días de trabajo (~4 semanas full-time) |
| Semanas full-time | 3.5 - 4 |
| Semanas part-time (4h/día) | 7 - 8 |
| Repos a tocar | 2 (`StrengthLabs` frontend, `StrengthLabsBackend` backend Java) |
| Stacks principales | Flutter/Dart + Java/Spring Boot + Python/FastAPI |
| Hito final | APK release firmado en español, conectado a backend real |

### Cronograma por semana

| Semana | Días | Foco principal | Hito |
|---|---|---|---|
| 1 | 1-5 | Setup + Mapeo + Schema + Auth | Login real funcionando |
| 2 | 6-10 | Workouts CRUD + Exercises + Fatigue | Dashboard de fatiga real |
| 3 | 11-15 | Routines + Export + i18n + Filtros | Features completas |
| 4 | 16-17 | Pre-release (iconos, signing, Google Sign-In) | APK release |

### Convenciones del documento

- **[B]** = tarea de backend
- **[F]** = tarea de frontend
- **[A]** = tarea ambos / contrato API / integración
- **[P]** = tarea paralelizable (se puede hacer en cualquier hueco)
- **⚙** = comando / acción técnica
- **✓** = hito verificable
- **⚠** = riesgo conocido o decisión a tomar

---

## SEMANA 1 — Setup, contrato y autenticación

### Día 0.5 — Setup y verificación (Fase 0)

**Objetivo**: confirmar que ambos componentes arrancan localmente.

#### Bloques restantes (la limpieza ya está hecha — ver CHECKLIST.md)

**Bloque 1 — Commits de seguridad** [A]
- ⚙ Commit en backend: sync compute engine + cleanup docker
- ⚙ Commit en frontend: limpieza repo + plan de trabajo
- ✓ `git status` limpio en ambos

**Bloque 2 — Schema provisional** [B]
- ⚙ `docker exec -i stlabs-postgres psql -U stlabs -d strengthlabs < ~/StrengthLabsBackend/schema.sql`
- ✓ `\dt` lista 3 tablas: `users`, `training_sessions`, `training_metrics`
- Nota: este schema se reemplaza completo en Día 2

**Bloque 3 — Backend Java arranca** [B]
- ⚙ Leer `src/main/resources/application.yml` y `application-dev.yml` para entender variables esperadas
- ⚙ Exportar lo que falte (`JWT_SECRET`, etc.)
- ⚙ `./mvnw spring-boot:run -Dspring-boot.run.profiles=dev`
- ✓ `curl http://localhost:8000/swagger-ui.html` devuelve HTML
- ⚠ Si falla: leer logs, corregir config (no código), reintentar

**Bloque 4 — Frontend arranca** [F]
- ⚙ `cd ~/StrengthLabs && flutter pub get && flutter run`
- ⚙ Login con `example@example.com / example`
- ✓ Las 5 tabs cargan sin errores con mock data

**Bloque 5 — Documentar lo encontrado** [A]
- Anotar en CHECKLIST.md qué endpoints existen realmente en el backend
- Listar cualquier config que haya hecho falta agregar

---

### Día 1 — Mapeo del contrato API (Fase 1)

**Objetivo**: tabla maestra que dicta el orden exacto de trabajo de
Días 2-13.

**Tarea única — `documentacion/api-contract.md`** [A]

Por cada endpoint que use el frontend:

1. Extraer del frontend (en `lib/features/*/data/*_repository.dart` y
   `lib/core/constants/api_constants.dart`):
   - Path
   - Método HTTP
   - Body que envía (con shape JSON)
   - Shape que parsea de la respuesta
2. Buscar el equivalente en el backend (en
   `src/main/java/com/strengthlabs/presentation/controllers/*.java`)
3. Marcar estado: ✓ alineado, ⚠ shape distinto, ❌ falta
4. Si ⚠ o ❌, escribir en una columna "Acción" qué hay que hacer

**Endpoints a auditar** (mínimo 20):

```
POST /auth/register
POST /auth/login
POST /auth/refresh
GET /auth/me
POST /auth/google
GET /workouts
POST /workouts
GET /workouts/{id}
PUT /workouts/{id}
DELETE /workouts/{id}
GET /exercises
POST /exercises
GET /fatigue/summary
GET /fatigue/weekly
GET /routines
GET /routines/{id}
GET /export/csv
GET /export/xlsx
```

✓ **Hito**: archivo `api-contract.md` con la tabla completa, lo usamos
como source of truth en todas las fases siguientes.

---

### Días 2-3 — Schema nuevo de BD (Fase 2)

**Objetivo**: las 8 tablas que necesita el frontend, versionadas con
Flyway.

#### Día 2

**2.1 — Diseñar schema final** [B]
- Reescribir `schema.sql` con 8 tablas: `users`, `exercises`, `workouts`,
  `workout_exercises`, `workout_sets`, `routines`, `routine_days`,
  `routine_exercises`. Mantener `training_metrics` como cache
- Decidir tipo de `id` para `routines`: VARCHAR(64) (`r-beg-strength`) vs
  UUID. **Recomendado**: VARCHAR(64) porque la doc usa IDs hablantes

**2.2 — Integrar Flyway** [B]
- ⚙ Agregar al `pom.xml`:
  ```xml
  <dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
  </dependency>
  <dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-database-postgresql</artifactId>
  </dependency>
  ```
- Mover schema a `src/main/resources/db/migration/V1__initial_schema.sql`
- Configurar `spring.flyway` en `application.yml`
- Cambiar `spring.jpa.hibernate.ddl-auto: validate`

**2.3 — Reset de BD** [B]
- ⚙ `docker exec stlabs-postgres dropdb -U stlabs strengthlabs`
- ⚙ `docker exec stlabs-postgres createdb -U stlabs strengthlabs`
- ⚙ Reiniciar backend, Flyway aplica V1 automáticamente

✓ **Hito día 2**: BD vacía con 9 tablas (8 nuevas + `training_metrics`).
`\dt` confirma. Backend arranca sin errores de Hibernate.

#### Día 3

**3.1 — JPA Entities** [B]
- Crear en `infrastructure/persistence/jpa/`:
  - `ExerciseJpaEntity`, `ExerciseJpaRepository`
  - `WorkoutJpaEntity`, `WorkoutJpaRepository`
  - `WorkoutExerciseJpaEntity`, `WorkoutExerciseJpaRepository`
  - `WorkoutSetJpaEntity`, `WorkoutSetJpaRepository`
  - `RoutineJpaEntity`, `RoutineJpaRepository`
  - `RoutineDayJpaEntity`, `RoutineDayJpaRepository`
  - `RoutineExerciseJpaEntity`, `RoutineExerciseJpaRepository`

**3.2 — Domain Entities + Ports** [B]
- Crear en `domain/entities/`:
  - `Exercise`, `Workout`, `WorkoutExercise`, `WorkoutSet`, `Routine`,
    `RoutineDay`, `RoutineExercise`
- Crear en `domain/repositories/` (interfaces puras):
  - `ExerciseRepository`, `WorkoutRepository`, `RoutineRepository`

**3.3 — Repository Adapters** [B]
- Crear en `infrastructure/persistence/adapters/`:
  - `ExerciseRepositoryAdapter implements ExerciseRepository`
  - Idem para Workout, Routine
- Mappers: JpaEntity ↔ Domain Entity

✓ **Hito día 3**: `./mvnw test` pasa. Inserts manuales con `psql`
funcionan. Hibernate no se queja del schema.

---

### Días 4-5 — Auth alineado (Fase 3)

**Objetivo**: login real funcionando desde el frontend.

#### Día 4

**4.1 — Auditar `JwtTokenProvider`** [B]
- Verificar que usa **HS256** (no RS256)
- Si usa RS256, cambiar a HS256 (frontend asume HS256)
- ✓ Verificar que el access token tiene `exp`, `sub` (UUID), claims
  esperados

**4.2 — Resolver `username`** [B]
- Backend tiene `username` único obligatorio, frontend solo manda email
- En `RegisterUseCase`: derivar `username = email.split('@')[0]`
- Si choca, agregar sufijo numérico: `oscar`, `oscar1`, `oscar2`...

**4.3 — Verificar shape de responses** [A]
- `POST /auth/register` y `POST /auth/login` devuelven:
  ```json
  {"access_token": "...", "refresh_token": "..."}
  ```
- `GET /auth/me` devuelve:
  ```json
  {"id": "...", "name": "...", "email": "..."}
  ```
- `POST /auth/refresh` recibe `{"refresh_token": "..."}`, devuelve par
  nuevo

**4.4 — Implementar `POST /auth/refresh` si no existe** [B]
- Validar el refresh token (firma + expiración + matching en BD si se
  guarda hash)
- Generar par nuevo
- Devolver mismo shape que login

✓ **Hito día 4**: con curl, podés registrar, loguearte y refrescar token.

#### Día 5

**5.1 — Implementar `POST /auth/google`** [B]
- Agregar dependencia `google-api-client` al `pom.xml`
- Recibir `{"id_token": "..."}` desde frontend
- Verificar contra Google con `GoogleIdTokenVerifier`
- Si email no existe → crear user (con `username` derivado, password
  random hasheado, role USER)
- Devolver `{access_token, refresh_token}`

**5.2 — Probar end-to-end desde frontend** [F]
- ⚙ Cambiar `lib/core/constants/api_constants.dart` baseUrl si hace falta
  (probablemente ya está OK con `http://10.0.2.2:8000`)
- ⚙ `flutter run` con backend levantado
- Login con usuario nuevo desde la app

⚠ **Riesgo**: Google Sign-In requiere `google-services.json` y
`serverClientId`. Si no está configurado, el botón Google falla. Saltar
esto y cubrirlo en Día 16

✓ **Hito día 5**: en el frontend, registrás un usuario nuevo, queda en
Postgres, te logueás y entrás a la pantalla de workouts (vacía porque
todavía no hay endpoints CRUD).

---

## SEMANA 2 — Workouts, Exercises y Fatigue

### Días 6-9 — Workouts CRUD + Exercises (Fase 4)

**Objetivo**: crear/listar/editar/borrar workouts contra backend real.

#### Día 6

**6.1 — ExerciseController** [B]
- Crear `presentation/controllers/ExerciseController.java`
- Endpoints:
  - `GET /exercises` → lista global + custom del user autenticado
  - `POST /exercises` → crear custom (body: `{name, muscle_group}`)
- Crear `application/usecases/ListExercisesUseCase` y `CreateCustomExerciseUseCase`

**6.2 — Refactor `ExerciseDataSeeder`** [B]
- Reemplazar la lista vieja con los **62 ejercicios globales** del Doc
  General Anexo A
- Verificar idempotencia: si la tabla tiene > 0 globales, no insertar

✓ **Hito día 6**: `GET /exercises` devuelve 62 globales. Crear custom
desde frontend funciona.

#### Día 7

**7.1 — Borrar SessionController viejo** [B]
- ⚙ `git rm src/main/java/com/strengthlabs/presentation/controllers/SessionController.java`
- Borrar `RegisterSessionUseCase`, `SessionInputDTO` y todo lo que
  dependía del modelo plano

**7.2 — WorkoutController esqueleto** [B]
- Crear `WorkoutController` con `@RequestMapping("/workouts")` (sin
  `/api/v1`)
- Stubs de los 5 endpoints (sin lógica todavía):
  - `GET /workouts`
  - `POST /workouts`
  - `GET /workouts/{id}`
  - `PUT /workouts/{id}`
  - `DELETE /workouts/{id}`

**7.3 — DTOs de entrada/salida** [B]
- `WorkoutDTO` (response): id, name, date, duration_seconds, notes,
  exercises (con sets anidados)
- `CreateWorkoutDTO` (request POST): name, date, duration_seconds, notes,
  exercises[{exercise_id, order, sets[{weight, reps, rpe, order}]}]
- `UpdateWorkoutDTO` (request PUT): name, notes
- Mappers entre DTO y domain Entity

✓ **Hito día 7**: backend arranca, Swagger muestra los 5 endpoints
nuevos.

#### Día 8

**8.1 — `CreateWorkoutUseCase`** [B]
- Recibe `CreateWorkoutDTO` + userId
- Valida que cada `exercise_id` exista
- Crea `Workout` con `WorkoutExercise[]` y cada uno con `WorkoutSet[]`
- Persiste en cascada
- Disparar evento `WorkoutCreated` (para el cálculo de métricas
  posterior, lo conectamos en Día 11)

**8.2 — `ListWorkoutsUseCase` + `GetWorkoutByIdUseCase`** [B]
- List: paginar después; por ahora todos los del user, orden por fecha
  desc
- Get: 404 si no existe o no es del user (ownership check)

**8.3 — `UpdateWorkoutUseCase` + `DeleteWorkoutUseCase`** [B]
- Update solo `name` y `notes` (lo único que el frontend edita)
- Delete con cascade (configurado en JPA con `CascadeType.ALL` o en
  schema con `ON DELETE CASCADE`)

✓ **Hito día 8**: con curl podés crear un workout con 3 ejercicios y 4
sets, listarlo, editar nombre, borrarlo.

#### Día 9

**9.1 — Conectar frontend a workouts reales** [F]
- ⚙ Limpiar mocks usados en el WorkoutRepository del frontend
- Verificar que el modo demo sigue funcionando como fallback de
  presentación (no romperlo)
- Probar end-to-end: crear workout en la app → verificar en Postgres →
  listar → editar → borrar

**9.2 — Bug fixes que vayan saliendo** [F][B]
- Cualquier mismatch de shape, ajustar uno u otro lado
- Documentar en CHECKLIST.md cualquier sorpresa

✓ **Hito día 9**: end-to-end de workouts funciona desde la app. Modo
demo sigue funcionando.

---

### Días 10-11 — Fatigue + Compute Engine (Fase 5)

**Objetivo**: dashboard de fatiga muestra datos reales calculados por el
compute engine.

#### Día 10

**10.1 — Refactor `PythonComputeAdapter`** [B]
- Actualizar para llamar a la versión NUEVA del compute engine
  (sincronizado en Día 0.5)
- `computeFatigue(sessions)` devuelve los 10 campos: atl, ctl, acwr, tsb,
  monotony, strain, ramp_rate, readiness_score, risk_flags, atl_series
- `computeRisk(metrics)` devuelve injury_risk_score,
  overtraining_risk_score, composite_risk_score, risk_level,
  dominant_factor, recommendations
- `computePlan(metrics)` recibe los 12 parámetros, devuelve plan completo
- Actualizar `FatigueResultDTO` y crear `RiskResultDTO`, `PlanResultDTO`

**10.2 — Actualizar tests del compute engine** [B]
- Reescribir `tests/test_fatigue_model.py` con los nuevos asserts
- Reescribir `tests/test_risk_model.py` con la nueva key (`risk_score`
  ya no existe, ahora es `composite_risk_score`)
- Agregar `tests/test_periodization_model.py`
- ⚙ `pytest tests/ -v` debe pasar todo

✓ **Hito día 10**: tests del compute engine pasan. `PythonComputeAdapter`
compila y devuelve datos completos.

#### Día 11

**11.1 — Refactor `FatigueController`** [B]
- `GET /fatigue/summary` con shape exacto que parsea
  `FatigueRepository.getSummary()` en frontend
- Internamente:
  1. Cargar workouts últimos 90 días del user
  2. Convertir a `[{date, duration_minutes, rpe}]` con `load = duration ×
     avg_rpe`
  3. Llamar `POST /compute/fatigue` y `POST /compute/risk` vía adapter
  4. Calcular `weekly_volume` por muscle_group (sumar peso × reps de cada
     set)
  5. Generar `trend` con últimos 14 días
  6. Combinar todo y devolver
- `GET /fatigue/weekly` → mismo formato pero solo weekly_volume

**11.2 — Cache en `training_metrics`** [B]
- Después de cada cálculo, upsert en `training_metrics` (`INSERT ... ON
  CONFLICT (user_id, metric_date) DO UPDATE`)
- En siguientes requests del mismo día, devolver cache si no hay workouts
  nuevos

**11.3 — Conectar frontend** [F]
- Verificar parseo de `FatigueRepository` con datos reales
- Probar dashboard de fatiga end-to-end

✓ **Hito día 11**: dashboard de fatiga muestra readiness, ATL/CTL/TSB,
gráfico de tendencia, recomendaciones contextuales con datos reales.

---

## SEMANA 3 — Routines, Export, frontend cleanup

### Días 12-13 — Routines + Export (Fase 6)

#### Día 12 — Routines

**12.1 — RoutineController** [B]
- Crear `RoutineController` en `presentation/controllers/`
- Endpoints:
  - `GET /routines?level=beginner|intermediate|advanced` →
    `{items: [routine]}`
  - `GET /routines/{id}` → routine completa con days y exercises

**12.2 — RoutineSeeder** [B]
- Crear `RoutineDataSeeder` que inserta las 5 rutinas del Doc General
  Anexo B si la tabla está vacía (idempotente):
  - `r-beg-strength` — 3-Day Beginner Strength
  - `r-int-hyp` — 4-Day Upper/Lower Hypertrophy
  - `r-adv-str` — 5-Day Advanced Powerbuilding
  - `r-beg-gen` — 3-Day Beginner General Fitness
  - `r-int-end` — 4-Day Intermediate Endurance + Strength

**12.3 — Conectar frontend** [F]
- Verificar `RoutineRepository.getRoutines()` parsea bien
- Probar cargar rutina desde RoutineDetailPage e iniciarla como template
  de active workout

✓ **Hito día 12**: pestaña Routines muestra las 5 rutinas reales,
podés iniciar una y aparece en Active Workout.

#### Día 13 — Export

**13.1 — ExportController** [B]
- Crear con dependencias en `pom.xml`:
  ```xml
  <dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>5.2.5</version>
  </dependency>
  ```
- Endpoints:
  - `GET /export/xlsx` → application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  - `GET /export/csv` → text/csv
- Columnas: Date, Workout, Exercise, Muscle Group, Set #, Weight (kg),
  Reps, RPE, Volume (kg)
- Una fila por cada set, ordenado por fecha desc

**13.2 — Decidir si frontend usa endpoints o ExportService local** [F]
- El frontend YA tiene su propio `ExportService` que genera archivos
  on-device
- Para v1.0 mobile: dejar el local (no requiere internet, más rápido)
- Los endpoints quedan disponibles para una web futura

✓ **Hito día 13**: backend tiene endpoints de export funcionando.
Frontend sigue exportando local (no se cambia).

---

### Días 14-15 — Frontend cleanup + features pendientes

Estos dos días son para todo lo que se puede hacer en paralelo durante
las fases anteriores y todavía no hicimos.

#### Día 14 — Cleanup técnico + i18n

**14.1 — Borrar código muerto** [F][P]
- ⚙ Borrar `lib/core/storage/workout_local_storage.dart`
- Refactor: `lib/features/fatigue/data/compute_repository.dart`:
  - Borrar método `computeMetrics()` (no se invoca de ningún lado)
  - Renombrar clase `ComputeRepository` → `PlanBuilder`
  - Sacarle la dependencia de `WorkoutLocalStorage`
- Mergear `lib/features/plan/data/plan_repository.dart` con `PlanBuilder`
  (es wrapper trivial)
- Actualizar `lib/app.dart`: sacar inyección de `WorkoutLocalStorage`
- Quitar `shared_preferences` del `pubspec.yaml`
- ⚙ `flutter pub get && flutter analyze` debe pasar

**14.2 — Cleanup de UI** [F][P]
- Quitar credenciales precargadas en
  `lib/features/auth/presentation/pages/login_page.dart:20-21`
- Decidir qué hacer con modo demo: borrarlo o esconderlo detrás de flag
- Centralizar `_parseMuscleGroup` (duplicado en 3 archivos):
  moverlo como método estático en enum `MuscleGroup`

**14.3 — i18n a español** [F][P]
- Agregar al `pubspec.yaml`:
  ```yaml
  dependencies:
    flutter_localizations:
      sdk: flutter
  ```
- Habilitar generación: en `pubspec.yaml`:
  ```yaml
  flutter:
    generate: true
  ```
- Crear `lib/l10n/app_es.arb` con todas las strings
- Crear `l10n.yaml` en root con config
- Convertir `AppStrings` a `AppLocalizations.of(context).xxx`
- Actualizar `lib/app.dart`:
  ```dart
  MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    ...
  )
  ```

✓ **Hito día 14**: app en español, sin código muerto, `flutter analyze`
con 0 issues.

#### Día 15 — Filtros y mejoras UX

**15.1 — Filtros del historial** [F]
- En `lib/features/workouts/presentation/pages/workout_list_page.dart`:
  - Agregar `DateRangePicker` para filtrar por fechas
  - Agregar `FilterChip`s para `MuscleGroup`
  - Conectar al `WorkoutsCubit.inRange()` que ya existe
- Persistir filtros en `WorkoutsCubit` para no perderlos al navegar

**15.2 — Búsqueda en exercise picker** [F]
- En `lib/features/workouts/presentation/pages/active_workout_page.dart`:
  - Verificar si el picker de ejercicios ya tiene búsqueda
  - Si no, agregar `TextField` con filtro por nombre
  - Combinar con filtro por muscle group

**15.3 — Confirmación al borrar workout** [F]
- En `lib/features/workouts/presentation/pages/workout_detail_page.dart`:
  - Verificar si ya hay `AlertDialog` al borrar
  - Si no, agregarlo con texto "¿Eliminar este entrenamiento?"

✓ **Hito día 15**: filtros funcionan, búsqueda funciona, borrado pide
confirmación. UX de v1.0 completa.

---

## SEMANA 4 — Pre-release y release

### Día 16 — Configuración de release

#### 16.1 — applicationId y namespace [F]
- ⚙ En `android/app/build.gradle.kts`:
  - Cambiar `namespace = "com.example.strengthlabs_beta"` →
    `"com.strengthlabs.app"`
  - Cambiar `applicationId = "com.example.strengthlabs_beta"` → idem
- ⚙ Mover `MainActivity.kt` a la nueva package path
- ⚙ Actualizar `AndroidManifest.xml` si referencia el package viejo
- ⚙ `flutter clean && flutter run` para verificar

#### 16.2 — Iconos y splash [F]
- Diseñar (o conseguir) un PNG 1024x1024 del logo
- ⚙ Agregar al `pubspec.yaml`:
  ```yaml
  dev_dependencies:
    flutter_launcher_icons: ^0.13.1
    flutter_native_splash: ^2.4.0
  flutter_icons:
    android: true
    ios: true
    image_path: "assets/icon.png"
  flutter_native_splash:
    color: "#0F1115"
    image: "assets/splash.png"
  ```
- ⚙ `flutter pub run flutter_launcher_icons:main`
- ⚙ `flutter pub run flutter_native_splash:create`

#### 16.3 — Google Sign-In real [F][B]
- En Google Cloud Console:
  1. Crear proyecto "StrengthLabs"
  2. Habilitar Google Sign-In API
  3. OAuth consent screen (User Type: External, scopes: email, profile)
  4. Crear OAuth Client IDs:
     - Android (con package name + SHA-1 del keystore release)
     - iOS (con bundle ID)
     - Web (para `serverClientId` que verifica el id_token en backend)
- ⚙ Descargar `google-services.json` → `~/StrengthLabs/android/app/`
- ⚙ Agregar plugin Google Services en `android/build.gradle.kts` y
  `android/app/build.gradle.kts`
- En `lib/features/auth/data/auth_repository.dart`:
  ```dart
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '<WEB_CLIENT_ID>.apps.googleusercontent.com',
  );
  ```
- En backend, configurar `GoogleIdTokenVerifier` con el mismo Web Client
  ID

✓ **Hito día 16**: app instalada con icono propio, splash propio, login
con Google funciona end-to-end.

---

### Día 17 — Build release y validación

#### 17.1 — Keystore release [F]
- ⚙ Crear keystore (UNA SOLA VEZ, guardar bien — sin esto no se actualiza
  la app en Play Store nunca):
  ```bash
  keytool -genkey -v -keystore ~/strengthlabs-release.jks \
          -keyalg RSA -keysize 2048 -validity 10000 \
          -alias strengthlabs
  ```
- Backup del keystore en lugar seguro (drive, password manager)
- Crear `~/StrengthLabs/android/key.properties` (en .gitignore):
  ```
  storePassword=...
  keyPassword=...
  keyAlias=strengthlabs
  storeFile=/home/ocruz/strengthlabs-release.jks
  ```
- Configurar signing en `android/app/build.gradle.kts`:
  ```kotlin
  val keyProperties = Properties()
  val keyPropsFile = rootProject.file("key.properties")
  if (keyPropsFile.exists()) {
      keyProperties.load(FileInputStream(keyPropsFile))
  }

  android {
      signingConfigs {
          create("release") {
              storeFile = file(keyProperties["storeFile"] as String)
              storePassword = keyProperties["storePassword"] as String
              keyAlias = keyProperties["keyAlias"] as String
              keyPassword = keyProperties["keyPassword"] as String
          }
      }
      buildTypes {
          release {
              signingConfig = signingConfigs.getByName("release")
          }
      }
  }
  ```

#### 17.2 — Build release [F]
- ⚙ `flutter build apk --release`
- ⚙ Verificar tamaño y firma:
  ```bash
  ls -lh build/app/outputs/flutter-apk/app-release.apk
  apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk
  ```

#### 17.3 — Testing end-to-end con build release [F]
- ⚙ Instalar APK release en device físico:
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```
- Probar todos los flujos:
  1. Registrar usuario nuevo
  2. Login con Google
  3. Crear workout con 3 ejercicios y 4 sets
  4. Ver dashboard de fatiga
  5. Ver y empezar una rutina predefinida
  6. Ver plan generado
  7. Exportar a XLSX y compartir por WhatsApp
  8. Logout y login normal con email/password

#### 17.4 — Documentación final [A]
- Actualizar `~/StrengthLabs/README.md` con:
  - Stack actual real (Java, no Python)
  - Comandos de setup actualizados
  - URL del backend en producción cuando exista
- Actualizar `Doc General.pdf` (o reescribir como v1.1) con cualquier
  divergencia que haya quedado del código real
- Borrar `~/StrengthLabs/documentacion/Arquitectura.pdf` (versión
  Python obsoleta)

✓ **Hito día 17 (FINAL)**: APK release firmado, instalable, app en
español con todos los flujos probados. Lista para subir a Google Play
canal interno.

---

## Tareas paralelizables (se pueden hacer en cualquier hueco)

Si en algún día queda tiempo o tenés que esperar a que algo del backend
compile/se levante, agarrá una de estas:

- [P] [F] Quitar `unused_field` warning en `export_service.dart:20` (`_filenameFmt`)
- [P] [F] Centralizar todos los strings hardcoded en `AppStrings` antes
  de migrar a i18n
- [P] [F] Agregar tests unitarios de `Validators` en
  `lib/shared/utils/validators.dart`
- [P] [F] Agregar tests del cálculo de plan en `compute_repository.dart`
  (si decidís mantenerlo) o de los formatters
- [P] [B] Agregar tests de cada UseCase nuevo a medida que los crees
- [P] [B] Configurar profile `prod` en `application-prod.yml` con
  variables externalizadas
- [P] [A] Mantener `CHECKLIST.md` y `ROADMAP.md` actualizados con
  cambios o sorpresas

---

## Checklist global de hitos

Marcar al cumplir:

### Setup y contrato
- [ ] Día 0.5: Frontend y backend Java arrancan
- [ ] Día 1: `api-contract.md` completo

### BD y autenticación
- [ ] Día 2: 9 tablas en Postgres con Flyway V1
- [ ] Día 3: JPA entities + adapters compilados
- [ ] Día 4: Auth con curl funciona (register, login, refresh)
- [ ] Día 5: Login real desde la app funciona

### Workouts y exercises
- [ ] Día 6: 62 ejercicios globales en BD
- [ ] Día 7: WorkoutController con 5 endpoints stubs
- [ ] Día 8: CRUD de workouts funciona con curl
- [ ] Día 9: CRUD de workouts funciona end-to-end desde la app

### Fatigue
- [ ] Día 10: PythonComputeAdapter actualizado, tests pasan
- [ ] Día 11: Dashboard de fatiga real funciona end-to-end

### Routines y export
- [ ] Día 12: 5 rutinas seeded, app las muestra
- [ ] Día 13: Export endpoints en backend (frontend sigue local)

### Cleanup y UX
- [ ] Día 14: App en español, sin código muerto, `flutter analyze` limpio
- [ ] Día 15: Filtros, búsqueda y confirmación al borrar funcionan

### Pre-release
- [ ] Día 16: applicationId propio, iconos, splash, Google Sign-In real
- [ ] Día 17: APK release firmado, todos los flujos probados, docs
      actualizados

---

## Después del Día 17 (no en este roadmap, pero anotado)

Roadmap futuro según `Arquitectura.pdf §9`:

- **v1.1** — Notificaciones push (FCM)
- **v1.2** — HRV como input adicional al modelo de readiness
- **v1.3** — Integración con Apple Health y Google Fit
- **v2.0** — Panel de administración web (React + FastAPI o seguir Java)

---

## Cambios a este documento

| Fecha | Cambio |
|---|---|
| 2026-05-04 | Versión inicial — cronograma completo de 17 días |
