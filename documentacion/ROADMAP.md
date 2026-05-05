# Roadmap detallado — StrengthLabs

> **Reescalado el 2026-05-04** después de descubrir que el backend de
> Yeisen está MUCHO más completo de lo asumido inicialmente. Estimación
> bajó de 17 días a **~8 días de trabajo**.

Este documento es el cronograma día por día de todo lo que vamos a hacer
hasta tener la app lista para release. Cada día tiene tareas concretas
con archivos, comandos y un hito verificable.

Para el plan macro y decisiones arquitectónicas: ver `PLAN.md`.
Para el estado actual y próximo paso inmediato: ver `CHECKLIST.md`.

---

## Resumen ejecutivo

| Métrica | Valor |
|---|---|
| Días totales estimados | **8 días** de trabajo (~2 semanas full-time) |
| Semanas full-time | 1.5 - 2 |
| Semanas part-time (4h/día) | 3 - 4 |
| Repos a tocar | 2 (`StrengthLabs` frontend, `StrengthLabsBackend` backend Java) |
| Stacks principales | Flutter/Dart + Java/Spring Boot + Python/FastAPI |
| Hito final | APK release firmado en español, conectado a backend real |

### Lo que cambió respecto a la versión anterior

Al levantar el backend Java por primera vez descubrimos que Yeisen ya
implementó casi todo:

- **9 controllers** ya existen y funcionan: Auth, Workout, Exercise,
  Routine, Fatigue, Export, Admin, Metrics (más SessionController viejo
  que se borra)
- **Modelo jerárquico ya implementado** en JPA: User, Exercise, Workout,
  WorkoutExercise, WorkoutSet
- **Shapes de respuestas alineados** con lo que parsea el frontend
  (snake_case, formato `{items: []}`, etc.)
- **62 ejercicios globales** ya seeded en BD
- **5 rutinas canónicas** seeded con IDs `r-beg-strength`, etc.
- **Auth funcional**: register/login/refresh/me devuelven JWT RS256

Lo que sigue faltando:
- `POST /auth/google` (auth con Google)
- `PythonComputeAdapter` está alineado al compute engine VIEJO
  (refactor pendiente, ver Día 4)
- `SessionController` viejo a borrar (limpieza)
- Verificación fina de cada shape contra el frontend
- TODO el trabajo del frontend (cleanup, i18n, filtros, pre-release)

### Cronograma por semana

| Semana | Días | Foco principal | Hito |
|---|---|---|---|
| 1 | 1-4 | Conectar frontend a backend real + auth Google + compute engine | Dashboard de fatiga real funcionando |
| 2 | 5-8 | Frontend cleanup + i18n + filtros + pre-release | APK release firmado |

### Convenciones del documento

- **[B]** = tarea de backend
- **[F]** = tarea de frontend
- **[A]** = tarea ambos / contrato API / integración
- **[P]** = tarea paralelizable (se puede hacer en cualquier hueco)
- **⚙** = comando / acción técnica
- **✓** = hito verificable
- **⚠** = riesgo conocido o decisión a tomar

---

## Día 0.5 — Setup y verificación (Fase 0) — ✓ COMPLETO

**Hito alcanzado**: backend Java arranca en `:8000`, compute engine en
`:8001`, Postgres + Redis corriendo, Swagger UI carga, auth con curl
funciona.

### Lo hecho (cerrado)

- ✓ Tooling verificado (Docker, JDK 21, Python, Flutter)
- ✓ Sincronización del compute engine (versión nueva en `recursos/`)
- ✓ Limpieza: `~/StrengthLabs/backend/`, `.vscode/settings.json`,
  `Arquitectura(deprecated).pdf`
- ✓ docker-compose.yml limpio, `.gitignore` Python actualizado
- ✓ Postgres 16 + Redis 7 corriendo
- ✓ Compute engine Python responde `/health`
- ✓ Backend Java arrancado: fix `@EnableJpaRepositories` +
  `@EntityScan` agregado a `StrengthLabsApiApplication.java` (en Spring
  Boot 4 `EntityScan` se movió a `org.springframework.boot.persistence.autoconfigure`)
- ✓ `POST /auth/register` devuelve 201 con tokens RS256
- ✓ Hibernate creó 6 tablas con el modelo jerárquico desde JPA entities
- ✓ Seeders corren: 62 ejercicios + 5 rutinas

### Lo pendiente del Bloque 0

- ⏳ **Bloque 4 — Arrancar frontend en modo demo** (te toca a vos):
  ```bash
  cd ~/StrengthLabs && flutter pub get && flutter run
  ```
  Verificar que las 5 tabs cargan con mock data sin errores.

---

## Día 1 — Mapeo del contrato API y verificación de shapes

**Objetivo**: confirmar que cada endpoint del backend devuelve EXACTAMENTE
lo que el frontend parsea. Cualquier mismatch se detecta hoy.

### 1.1 Auditoría endpoint por endpoint [A]

Por cada endpoint, comparar:
- **Request**: shape que el frontend envía vs lo que el backend espera
- **Response**: shape que el backend devuelve vs lo que el frontend
  parsea (en `lib/features/*/data/*_repository.dart`)

Endpoints a auditar (ya existen en backend):

| Endpoint | Frontend repo | Estado a probar |
|---|---|---|
| `POST /auth/register` | `auth_repository.dart:42` | ✓ probado, 201 OK |
| `POST /auth/login` | `auth_repository.dart:25` | ✓ probado |
| `POST /auth/refresh` | `dio_client.dart:102` | ⏳ probar |
| `GET /auth/me` | `auth_repository.dart:54` | ✓ probado |
| `POST /auth/google` | `auth_repository.dart:74` | ❌ no existe en backend |
| `GET /exercises` | `workout_repository.dart:124` | ✓ probado |
| `POST /exercises` | `workout_repository.dart:106` | ⏳ probar |
| `GET /workouts` | `workout_repository.dart:12` | ✓ probado (vacío) |
| `POST /workouts` | `workout_repository.dart:20` | ⏳ probar con body real |
| `GET /workouts/{id}` | (cubit) | ⏳ probar |
| `PUT /workouts/{id}` | `workout_repository.dart:73` | ⏳ probar |
| `DELETE /workouts/{id}` | `workout_repository.dart:98` | ⏳ probar |
| `GET /fatigue/summary` | `fatigue_repository.dart:11` | ⚠ probar — adapter viejo |
| `GET /fatigue/weekly` | `api_constants.dart:28` | ⏳ probar |
| `GET /routines` | `routine_repository.dart:12` | ✓ probado |
| `GET /routines/{id}` | `routine_repository.dart:29` | ⏳ probar |
| `GET /export/csv` | (no usado) | ⏳ probar (frontend exporta local) |
| `GET /export/xlsx` | (no usado) | ⏳ probar |

### 1.2 Documentar mismatches [A]

Crear `documentacion/api-contract.md` con:
- Tabla con estado de cada endpoint (probado/pendiente, OK/mismatch)
- Por cada mismatch: shape esperado vs shape real, acción concreta

### 1.3 Verificar JWT en el frontend [F]

- El frontend asume JWT con `exp` claim → backend lo incluye ✓
- El frontend NO valida firma (solo decodifica payload) → RS256 OK
- Verificar `lib/core/storage/token_storage.dart:isAccessTokenExpired()`
  funciona con tokens RS256 reales

✓ **Hito día 1**: `api-contract.md` con todos los endpoints marcados,
mismatches identificados.

---

## Día 2 — Conectar frontend a backend real + arreglar mismatches

**Objetivo**: la app deja de usar mocks y se conecta al backend en `:8000`.

### 2.1 Configuración inicial [F]

- ⚙ Verificar `lib/core/constants/api_constants.dart` — debería estar OK
  con `baseUrl = http://10.0.2.2:8000` para emulador Android
- ⚙ Si querés probar con device físico, pasar al run:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://192.168.X.X:8000
  ```

### 2.2 Test end-to-end manual [F]

Escenarios mínimos a probar (con backend levantado):
1. **Register** un usuario nuevo desde la app
2. **Login** con ese usuario
3. **Logout** y verificar que vuelve a /login
4. **Crear workout** con 2 ejercicios y 3 sets cada uno
5. **Ver el workout** en la lista (refresh)
6. **Editar nombre** del workout
7. **Borrar workout** y verificar que desaparece
8. **Cargar exercises** en el picker de active workout
9. **Crear ejercicio custom** y verificarlo en lista
10. **Cargar rutinas** en pestaña Routines
11. **Iniciar rutina** como template de active workout
12. **Cargar dashboard de fatiga** (puede estar limitado por compute viejo)

### 2.3 Arreglar mismatches que aparezcan [F][B]

Cualquier diferencia de shape que aparezca: ajustar UN lado u otro
según convenga. Documentar en CHECKLIST.md.

⚠ **Esperado**: el dashboard de fatiga puede no funcionar bien porque
`PythonComputeAdapter` aún llama al compute engine viejo (4 campos)
mientras el frontend espera 20+ campos. Lo arreglamos en Día 4.

✓ **Hito día 2**: 10 de los 12 escenarios funcionan. Los 2 que fallen
están documentados con causa raíz.

---

## Día 3 — Limpieza backend + POST /auth/google

### 3.1 Borrar `SessionController` viejo y todo lo relacionado [B]

- ⚙ `git rm` de:
  - `presentation/controllers/SessionController.java`
  - `application/dtos/SessionInputDTO.java`
  - `application/usecases/RegisterSessionUseCase.java`
  - `domain/entities/WorkoutSession.java`
  - `domain/repositories/SessionRepository.java`
  - `infrastructure/persistence/jpa/SessionJpaEntity.java`
  - `infrastructure/persistence/jpa/SessionJpaRepository.java`
  - `infrastructure/persistence/adapters/SessionRepositoryAdapter.java`
- Revisar que nada lo referencie aún (si sí, borrar también)
- Verificar `./mvnw test` pasa

⚠ La tabla `workout_sessions` quedará huérfana en la BD. Como
`ddl-auto: create-drop` en dev, se dropea al próximo restart. En prod
hay que migrar (Flyway).

### 3.2 Implementar `POST /auth/google` [B]

- Agregar dependencia al `pom.xml`:
  ```xml
  <dependency>
      <groupId>com.google.api-client</groupId>
      <artifactId>google-api-client</artifactId>
      <version>2.7.0</version>
  </dependency>
  ```
- Agregar endpoint en `AuthController`:
  - Recibe `{"id_token": "..."}`
  - Valida con `GoogleIdTokenVerifier`
  - Si email no existe → crea user con role USER y password random
    hasheado
  - Devuelve `{access_token, refresh_token}`
- Agregar variable de entorno `GOOGLE_CLIENT_ID` al `application.yml`

### 3.3 Frontend: probar Google Sign-In [F]

- Sin `google-services.json` aún, el botón Google fallará al obtener
  el ID token. Eso se resuelve en Día 7.
- Sí podés probar el endpoint backend con curl pasando un id_token de
  prueba.

✓ **Hito día 3**: `git diff --stat` del backend muestra ~10 archivos
borrados y `AuthController.java` con endpoint nuevo. `./mvnw test` pasa.

---

## Día 4 — Refactor PythonComputeAdapter al modelo nuevo

**Objetivo**: dashboard de fatiga muestra todos los datos científicos
correctamente.

### 4.1 Refactor `PythonComputeAdapter` [B]

Actualmente lee 4 campos (atl, ctl, acwr, tsb). El modelo nuevo del
compute engine devuelve 10+ campos. Refactor:

- `computeFatigue(sessions)` debe devolver `FatigueResultDTO` extendido
  con: monotony, strain, ramp_rate, readiness_score, risk_flags,
  atl_series
- `computeRisk(metrics)` recibe shape completo, devuelve
  injury_risk_score, overtraining_risk_score, composite_risk_score,
  risk_level, dominant_factor, recommendations
- `computePlan(metrics)` recibe los 12 parámetros (ctl, atl, tsb, acwr,
  monotony, ramp_rate, readiness_score, composite_risk,
  injury_risk_score, overtraining_risk_score, days_to_event,
  weeks_in_phase) y devuelve plan completo
- Crear `RiskResultDTO` y `PlanResultDTO`

### 4.2 Refactor `FatigueController` [B]

- `GET /fatigue/summary` debe devolver el shape exacto que parsea
  `FatigueRepository.getSummary()` en frontend (ver
  `lib/features/fatigue/data/fatigue_repository.dart:14`)
- Internamente:
  1. Cargar workouts últimos 90 días del user autenticado
  2. Convertir a `[{date, duration_minutes, rpe}]` con
     `load = duration × avg_rpe` (Foster)
  3. Llamar `POST /compute/fatigue` y `POST /compute/risk` vía adapter
  4. Calcular `weekly_volume` por muscle_group (sumar peso × reps)
  5. Generar `trend` con últimos 14 días
  6. Combinar y devolver

### 4.3 Actualizar tests del compute engine [B]

- Reescribir `tests/test_fatigue_model.py` con asserts del modelo nuevo
- Reescribir `tests/test_risk_model.py` (key `risk_score` → `composite_risk_score`)
- ⚙ `pytest recursos/tests/ -v` debe pasar todo

### 4.4 Probar dashboard end-to-end [F][B]

- Crear unos 5-10 workouts variados desde la app (días distintos)
- Cargar dashboard → verificar que aparece readiness, ATL/CTL/TSB,
  recomendaciones, gráfico de tendencia

✓ **Hito día 4**: dashboard de fatiga muestra datos completos.
`pytest` del compute engine pasa.

---

## Día 5 — Frontend cleanup técnico + i18n

### 5.1 Borrar código muerto [F][P]

- ⚙ Borrar `lib/core/storage/workout_local_storage.dart`
- Refactor `lib/features/fatigue/data/compute_repository.dart`:
  - Borrar método `computeMetrics()` (no se invoca de ningún lado)
  - Renombrar clase `ComputeRepository` → `PlanBuilder`
  - Sacarle dependencia de `WorkoutLocalStorage`
- Mergear `lib/features/plan/data/plan_repository.dart` con `PlanBuilder`
- Actualizar `lib/app.dart`: sacar inyección de `WorkoutLocalStorage`
- Quitar `shared_preferences` del `pubspec.yaml`
- ⚙ `flutter pub get && flutter analyze` debe pasar

### 5.2 Cleanup de UI [F][P]

- Quitar credenciales precargadas en `login_page.dart:20-21`
- Decidir qué hacer con modo demo: borrarlo o esconderlo detrás de flag
  `kDebugMode`
- Centralizar `_parseMuscleGroup` (duplicado en 3 archivos):
  moverlo como método estático en enum `MuscleGroup`

### 5.3 i18n a español [F]

- Agregar al `pubspec.yaml`:
  ```yaml
  dependencies:
    flutter_localizations:
      sdk: flutter
  flutter:
    generate: true
  ```
- Crear `l10n.yaml` en root con config
- Crear `lib/l10n/app_es.arb` con todas las strings
- Convertir `AppStrings` a `AppLocalizations.of(context).xxx`
- Actualizar `lib/app.dart` con localizationsDelegates y supportedLocales

✓ **Hito día 5**: app en español, sin código muerto, `flutter analyze`
con 0 issues.

---

## Día 6 — Filtros, búsqueda y mejoras UX

### 6.1 Filtros del historial [F]

En `lib/features/workouts/presentation/pages/workout_list_page.dart`:
- Agregar `DateRangePicker` para filtrar por fechas
- Agregar `FilterChip`s para `MuscleGroup`
- Conectar al `WorkoutsCubit.inRange()` que ya existe
- Persistir filtros en cubit

### 6.2 Búsqueda en exercise picker [F]

En `active_workout_page.dart`:
- Verificar si el picker ya tiene búsqueda
- Si no, agregar `TextField` con filtro por nombre
- Combinar con filtro por muscle group

### 6.3 Confirmación al borrar workout [F]

En `workout_detail_page.dart`:
- Verificar si ya hay `AlertDialog` al borrar
- Si no, agregarlo: "¿Eliminar este entrenamiento?"

### 6.4 Bug fixing del frontend [F]

- Lista de bugs/issues que vayan saliendo de los Días 2-5
- Cualquier mismatch de shape que se haya documentado

✓ **Hito día 6**: filtros funcionan, búsqueda funciona, borrado pide
confirmación, no hay bugs abiertos.

---

## Día 7 — Pre-release: applicationId, iconos, signing, Google

### 7.1 applicationId y namespace [F]

- ⚙ En `android/app/build.gradle.kts`:
  - `namespace = "com.example.strengthlabs_beta"` →
    `"com.strengthlabs.app"`
  - `applicationId = "com.example.strengthlabs_beta"` → idem
- ⚙ Mover `MainActivity.kt` al nuevo package path
- ⚙ Actualizar `AndroidManifest.xml` si referencia el package viejo
- ⚙ `flutter clean && flutter run`

### 7.2 Iconos y splash [F]

- Diseñar (o conseguir) PNG 1024x1024 del logo
- Agregar al `pubspec.yaml`:
  ```yaml
  dev_dependencies:
    flutter_launcher_icons: ^0.13.1
    flutter_native_splash: ^2.4.0
  ```
- ⚙ `flutter pub run flutter_launcher_icons:main`
- ⚙ `flutter pub run flutter_native_splash:create`

### 7.3 Google Sign-In real [F][B]

En Google Cloud Console:
1. Crear proyecto "StrengthLabs"
2. Habilitar Google Sign-In API
3. OAuth consent screen (User Type: External, scopes: email, profile)
4. Crear OAuth Client IDs:
   - Android (con package name + SHA-1 del keystore release)
   - iOS (con bundle ID)
   - Web (para `serverClientId` que verifica en backend)

Frontend:
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

Backend:
- Configurar `GoogleIdTokenVerifier` con el mismo Web Client ID
- Variable `GOOGLE_CLIENT_ID` en `application.yml`

✓ **Hito día 7**: app instalada con icono propio, splash propio, login
con Google funciona end-to-end.

---

## Día 8 — Build release y validación final

### 8.1 Keystore release [F]

⚙ Crear keystore (UNA SOLA VEZ — sin esto no se actualiza la app en Play
Store nunca):
```bash
keytool -genkey -v -keystore ~/strengthlabs-release.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias strengthlabs
```

Backup del keystore en lugar seguro (Drive, password manager).

Crear `~/StrengthLabs/android/key.properties` (en .gitignore):
```
storePassword=...
keyPassword=...
keyAlias=strengthlabs
storeFile=/home/ocruz/strengthlabs-release.jks
```

Configurar signing en `android/app/build.gradle.kts`:
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

### 8.2 Build release [F]

⚙ Comandos:
```bash
flutter build apk --release
ls -lh build/app/outputs/flutter-apk/app-release.apk
apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk
```

### 8.3 Testing end-to-end con build release [F]

⚙ Instalar APK release en device físico:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Probar todos los flujos:
1. Registrar usuario nuevo
2. Login con Google
3. Crear workout con 3 ejercicios y 4 sets
4. Ver dashboard de fatiga
5. Ver y empezar una rutina predefinida
6. Ver plan generado
7. Exportar a XLSX y compartir por WhatsApp
8. Logout y login con email/password

### 8.4 Documentación final [A]

- Actualizar `~/StrengthLabs/README.md`:
  - Stack actual real (Java/Spring Boot 4, no Python)
  - Comandos de setup actualizados
  - URL del backend en producción cuando exista
- Actualizar `Doc General.pdf` (o reescribir como v1.1) con cualquier
  divergencia que haya quedado del código real
- Borrar `~/StrengthLabs/documentacion/Arquitectura.pdf` (versión
  Python obsoleta)

✓ **Hito día 8 (FINAL)**: APK release firmado, instalable, app en
español con todos los flujos probados. Lista para subir a Google Play
canal interno.

---

## Tareas paralelizables (cualquier hueco)

Si en algún día queda tiempo o tenés que esperar a que algo del backend
compile/se levante, agarrá una de estas:

- [P] [F] Quitar `unused_field` warning en `export_service.dart:20`
  (`_filenameFmt`)
- [P] [F] Centralizar todos los strings hardcoded en `AppStrings` antes
  de migrar a i18n
- [P] [F] Agregar tests unitarios de `Validators` en
  `lib/shared/utils/validators.dart`
- [P] [B] Agregar tests de cada UseCase nuevo
- [P] [B] Configurar profile `prod` en `application-prod.yml` con
  variables externalizadas (JWT keys reales, DB password, etc.)
- [P] [A] Mantener `CHECKLIST.md` y `ROADMAP.md` actualizados con
  cambios o sorpresas

---

## Checklist global de hitos

Marcar al cumplir:

### Setup y verificación
- [x] Día 0.5: Backend Java arranca, Swagger carga, auth con curl funciona
- [ ] Día 0.5 final: Frontend arranca en modo demo

### Conexión frontend ↔ backend real
- [ ] Día 1: `api-contract.md` completo con shapes verificados
- [ ] Día 2: 12 escenarios funcionales end-to-end
- [ ] Día 3: SessionController borrado, POST /auth/google implementado
- [ ] Día 4: Dashboard de fatiga con datos reales completos

### Frontend cleanup y features
- [ ] Día 5: App en español, sin código muerto
- [ ] Día 6: Filtros, búsqueda y confirmación al borrar funcionan

### Pre-release
- [ ] Día 7: applicationId propio, iconos, splash, Google Sign-In real
- [ ] Día 8: APK release firmado, todos los flujos probados, docs
      actualizados

---

## Después del Día 8 (no en este roadmap, pero anotado)

Roadmap futuro según `Arquitectura.pdf §9`:

- **v1.1** — Notificaciones push (FCM)
- **v1.2** — HRV como input adicional al modelo de readiness
- **v1.3** — Integración con Apple Health y Google Fit
- **v2.0** — Panel de administración web (React + Spring Boot)

---

## Cambios a este documento

| Fecha | Cambio |
|---|---|
| 2026-05-04 (mañana) | Versión inicial — cronograma de 17 días |
| 2026-05-04 (tarde) | Reescalado a 8 días: descubrimos que Yeisen ya implementó casi todo el backend (controllers, modelo jerárquico, seeders, auth) |
