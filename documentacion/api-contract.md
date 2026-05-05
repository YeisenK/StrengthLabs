# Contrato API frontend ↔ backend

Auditoría exhaustiva endpoint por endpoint. Producido el **2026-05-04**
contra el backend Java tal como lo dejó Yeisen + el fix de Spring Boot 4
annotations (commit `efcb7c3`).

**Resultado global**: el contrato está **prácticamente 100% alineado**.
Solo **un endpoint falta** (`POST /auth/google`) y **un endpoint
funciona pero devuelve valores vacíos** (`GET /fatigue/summary` — el
`PythonComputeAdapter` está alineado al modelo viejo).

---

## Convenciones globales

- **Base URL**: `http://localhost:8000` (dev). Frontend usa
  `http://10.0.2.2:8000` desde emulador Android (loopback al host)
- **Sin prefijo `/api/v1/`** en endpoints de negocio (solo `/api/v1/admin/*`
  lo usa, frontend no lo consume)
- **JSON snake_case**: `access_token`, `refresh_token`, `weekly_volume`,
  `is_overtraining`, etc.
- **Auth**: Bearer token en header `Authorization: Bearer <jwt>`
- **JWT**: RS256 (frontend solo decodifica payload para leer `exp`, no
  valida firma — funciona con cualquier algoritmo)
- **Fechas**: ISO 8601 UTC (`2026-05-04T15:00:00Z`)
- **IDs**: UUID v4 generados por Postgres (excepto rutinas, que usan
  IDs hablantes tipo `r-beg-strength`)

---

## Tabla maestra

| # | Endpoint | Método | Estado | Notas |
|---|---|---|---|---|
| 1 | `/auth/register` | POST | ✓ | shape OK, 201 |
| 2 | `/auth/login` | POST | ✓ | shape OK |
| 3 | `/auth/refresh` | POST | ✓ | shape OK |
| 4 | `/auth/me` | GET | ✓ | shape OK |
| 5 | `/auth/google` | POST | ❌ | **NO existe** (403) — implementar Día 3 |
| 6 | `/exercises` | GET | ✓ | 62 ejercicios globales seeded |
| 7 | `/exercises` | POST | ✓ | 201, devuelve exercise creado |
| 8 | `/workouts` | GET | ✓ | `{items: []}` |
| 9 | `/workouts` | POST | ✓ | jerárquico, devuelve workout completo |
| 10 | `/workouts/{id}` | GET | ✓ | shape OK |
| 11 | `/workouts/{id}` | PUT | ✓ | actualiza name/notes |
| 12 | `/workouts/{id}` | DELETE | ✓ | 204 |
| 13 | `/fatigue/summary` | GET | ⚠ | shape OK, valores en 0 (compute adapter viejo) |
| 14 | `/fatigue/weekly` | GET | ✓ | `{weekly_volume: {...}}` con 12 grupos |
| 15 | `/routines` | GET | ✓ | 5 rutinas canónicas seeded |
| 16 | `/routines/{id}` | GET | ✓ | shape OK |
| 17 | `/export/csv` | GET | ✓ | text/csv, 9 columnas correctas |
| 18 | `/export/xlsx` | GET | ✓ | xlsx válido |

**Estados**:
- ✓ alineado y funcional
- ⚠ existe pero algo no calza (detalle en sección)
- ❌ falta implementar

---

## Detalle endpoint por endpoint

### 1. `POST /auth/register`

**Frontend**: `auth_repository.dart:42`

Request:
```json
{"name": "Oscar", "email": "oscar@example.com", "password": "test1234"}
```

Response 201:
```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci..."
}
```

✓ alineado

---

### 2. `POST /auth/login`

**Frontend**: `auth_repository.dart:25`

Request:
```json
{"email": "oscar@example.com", "password": "test1234"}
```

Response 200:
```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci..."
}
```

✓ alineado

---

### 3. `POST /auth/refresh`

**Frontend**: `dio_client.dart:102` (interceptor)

Request:
```json
{"refresh_token": "eyJhbGci..."}
```

Response 200:
```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci..."
}
```

✓ alineado

---

### 4. `GET /auth/me`

**Frontend**: `auth_repository.dart:54`

Headers: `Authorization: Bearer <access_token>`

Response 200:
```json
{
  "id": "9fd81635-529d-499a-85a5-63ede70e39ce",
  "name": "Oscar",
  "email": "oscar@example.com"
}
```

✓ alineado (no devuelve `role` ni `username`, lo cual está OK para el
frontend)

---

### 5. `POST /auth/google` — ❌ FALTA

**Frontend**: `auth_repository.dart:74`

El frontend envía:
```json
{"id_token": "<google_id_token>"}
```

Espera response 200/201 con:
```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci..."
}
```

**Estado actual**: backend devuelve **403 Forbidden**.

**Acción** (Día 3 del ROADMAP):
1. Agregar dependencia `google-api-client` al `pom.xml`
2. Crear endpoint en `AuthController`
3. Validar id_token con `GoogleIdTokenVerifier` (necesita
   `GOOGLE_CLIENT_ID` env var = Web Client ID de Google Cloud)
4. Si email no existe → crear user con role USER, password random
5. Devolver el mismo shape `{access_token, refresh_token}` que
   register/login

---

### 6. `GET /exercises`

**Frontend**: `workout_repository.dart:124`

Headers: `Authorization: Bearer <access_token>`

Response 200:
```json
[
  {
    "id": "93b6648e-2fb1-41a6-8553-e8af5a5fcedc",
    "name": "Barbell Bench Press",
    "muscle_group": "chest",
    "is_custom": false
  },
  ...
]
```

✓ alineado. **62 ejercicios globales** seeded por `ExerciseDataSeeder`.

**Muscle groups del backend** (12 valores): `chest, back, shoulders,
biceps, triceps, legs, core, glutes, calves, forearms, cardio, other`.
**Muscle groups del frontend** (6 valores): `chest, back, legs,
shoulders, arms, core`. El parseo en
`workout_repository.dart:174-196` mapea correctamente:
- `biceps`, `triceps`, `forearms` → `arms`
- `glutes`, `calves` → `legs`
- `cardio`, `other` → `core` (default)

---

### 7. `POST /exercises`

**Frontend**: `workout_repository.dart:106`

Request:
```json
{"name": "Mi ejercicio custom", "muscle_group": "chest"}
```

Response 201:
```json
{
  "id": "7111c0cd-292a-4b06-992e-186ed5f420e4",
  "name": "Mi ejercicio custom",
  "muscle_group": "chest",
  "is_custom": true
}
```

✓ alineado

---

### 8. `GET /workouts`

**Frontend**: `workout_repository.dart:12`

Response 200:
```json
{
  "items": [
    {
      "id": "...",
      "name": "Push Day Test",
      "date": "2026-05-04T15:00:00Z",
      "duration_seconds": 4500,
      "notes": "...",
      "exercises": [
        {
          "exercise": {"id": "...", "name": "...", "muscle_group": "chest", "is_custom": false},
          "sets": [
            {"id": "...", "weight": 80.0, "reps": 5, "rpe": 8.0}
          ]
        }
      ]
    }
  ]
}
```

✓ alineado (formato `{items: []}` correcto)

---

### 9. `POST /workouts`

**Frontend**: `workout_repository.dart:20`

Request (jerárquico):
```json
{
  "name": "Push Day Test",
  "date": "2026-05-04T15:00:00Z",
  "duration_seconds": 4500,
  "notes": "...",
  "exercises": [
    {
      "exercise_id": "<uuid>",
      "order": 0,
      "sets": [
        {"weight": 80, "reps": 5, "rpe": 8.0, "order": 0},
        {"weight": 80, "reps": 5, "rpe": 8.5, "order": 1}
      ]
    }
  ]
}
```

Response 201: workout completo con `id` y `exercise.id`/`set.id`
generados.

✓ alineado

---

### 10. `GET /workouts/{id}`

Response 200: mismo shape que un workout dentro de `items` en el GET
listado.

✓ alineado

---

### 11. `PUT /workouts/{id}`

**Frontend**: `workout_repository.dart:73`

Request (solo name/notes):
```json
{"name": "Push Day Editado", "notes": "..."}
```

Response 200: workout completo actualizado (mantiene exercises/sets).

✓ alineado

---

### 12. `DELETE /workouts/{id}`

Response 204 (sin body). Cascade borra `workout_exercises` y
`workout_sets`.

✓ alineado

---

### 13. `GET /fatigue/summary` — ⚠ FUNCIONA PERO VALORES VACÍOS

**Frontend**: `fatigue_repository.dart:11`

Response 200 (todas las 19 keys que el frontend espera):
```json
{
  "overall_index": 0.0,
  "is_overtraining": false,
  "weekly_volume": {"chest": 10.0, "back": 0.0, ...},
  "trend": [
    {"date": "2026-04-29", "index": 0.0},
    ...7 días...
  ],
  "atl": 0.0,
  "ctl": 0.0,
  "tsb": 0.0,
  "acwr": 0.0,
  "monotony": 0.0,
  "strain": 0.0,
  "ramp_rate": 0.0,
  "readiness_score": 0.0,
  "risk_flags": [],
  "injury_risk_score": 0.0,
  "overtraining_risk_score": 0.0,
  "composite_risk_score": 0.0,
  "risk_level": "low",
  "dominant_factor": "",
  "recommendations": []
}
```

**Problema**: el shape es correcto (19 campos exactos) y `weekly_volume`
sí tiene datos reales del workout creado (`chest: 10.0`), pero las
métricas científicas (ATL, CTL, etc.) están todas en 0.

**Causa**: el `PythonComputeAdapter` (en `infrastructure/compute/`)
está alineado al modelo VIEJO del compute engine — solo lee 4 campos
(atl, ctl, acwr, tsb). El compute engine nuevo devuelve 10+ campos
pero el adapter no los lee.

Adicionalmente, el compute engine puede no estar siendo invocado en
absoluto si:
- No está corriendo (no lo levanté en background después de las
  pruebas iniciales)
- El backend no maneja gracefully que no esté disponible

**Acción** (Día 4 del ROADMAP):
1. Refactor `PythonComputeAdapter.computeFatigue()` para devolver los
   10 campos del modelo nuevo
2. Crear/extender `FatigueResultDTO` con todos los campos
3. Refactor `FatigueController` o el UseCase para combinar
   `computeFatigue` + `computeRisk` y poblar todos los 19 campos del
   response
4. Asegurar que el compute engine esté corriendo o manejar fallback
   graceful

---

### 14. `GET /fatigue/weekly`

Response 200:
```json
{
  "weekly_volume": {
    "chest": 25.0,
    "back": 0.0,
    "shoulders": 0.0,
    "biceps": 0.0,
    "triceps": 0.0,
    "legs": 0.0,
    "core": 0.0,
    "glutes": 0.0,
    "calves": 0.0,
    "forearms": 0.0,
    "cardio": 0.0,
    "other": 0.0
  }
}
```

✓ funciona, **pero el frontend NO lo usa actualmente**. Lo declara en
`api_constants.dart:28` pero ningún repo lo llama. Está disponible si
en el futuro queremos un breakdown semanal separado.

---

### 15. `GET /routines`

**Frontend**: `routine_repository.dart:12`

Response 200:
```json
{
  "items": [
    {
      "id": "r-beg-strength",
      "name": "3-Day Beginner Strength",
      "level": "beginner",
      "goal": "strength",
      "days_per_week": 3,
      "description": "...",
      "days": [
        {
          "name": "Day A — Full Body",
          "exercises": [
            {
              "exercise": {"id": "ex-...", "name": "...", "muscle_group": "...", "is_custom": false},
              "sets": 3,
              "reps_scheme": "5",
              "notes": null
            }
          ]
        }
      ]
    }
  ]
}
```

Acepta query param `?level=beginner|intermediate|advanced`.

✓ alineado. **5 rutinas canónicas** ya seeded:
`r-beg-strength, r-int-hyp, r-adv-str, r-beg-gen, r-int-end`.

---

### 16. `GET /routines/{id}`

Response 200: routine completa con la misma estructura que un item del
listado.

✓ alineado

---

### 17. `GET /export/csv`

Response 200, `Content-Type: text/csv`.

Columnas:
```
Date, Workout, Exercise, Muscle Group, Set #, Weight (kg), Reps, RPE, Volume (kg)
```

Ejemplo:
```csv
Date,Workout,Exercise,Muscle Group,Set #,Weight (kg),Reps,RPE,Volume (kg)
2026-05-04,Push Day,Barbell Bench Press,chest,1,80.00,5,8.0,400.00
```

✓ funciona. **El frontend NO lo usa** — exporta on-device con su
`ExportService`. Disponible para uso desde web/herramientas externas.

---

### 18. `GET /export/xlsx`

Response 200,
`Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`.

Mismo contenido que CSV pero en formato Excel. Verificado: archivo es
"Microsoft Excel 2007+" válido (3.8 KB para un workout simple).

✓ funciona. Misma nota: **frontend no lo usa**, exporta on-device.

---

## Endpoints extras del backend (no consumidos por frontend)

| Endpoint | Propósito | ¿Usar? |
|---|---|---|
| `GET /auth/.well-known/jwks.json` | Publica clave pública RS256 para validación externa | No por ahora |
| `GET /api/v1/admin/users` | Lista usuarios (rol ADMIN) | No para v1.0 |
| `GET /api/v1/admin/users/{userId}` | Detalle user | No para v1.0 |
| `DEL /api/v1/admin/users/{userId}/deactivate` | Desactiva user | No para v1.0 |
| `GET /api/v1/dashboard` | Endpoint legacy del MetricsController | Borrar o ignorar |
| `GET /api/v1/sessions` | SessionController VIEJO | **Borrar Día 3** |
| `POST /api/v1/sessions` | Idem | **Borrar Día 3** |

---

## Resumen de acciones (alimenta los Días 2-4 del ROADMAP)

### Día 2 (mañana siguiente) — Conectar frontend al backend real

- Arrancar app contra `http://10.0.2.2:8000`
- Probar end-to-end los **12 escenarios** del ROADMAP
- Documentar cualquier bug que aparezca (no esperamos sorpresas grandes
  porque el contrato está alineado)

### Día 3 — POST /auth/google + limpieza

1. Implementar `POST /auth/google` (ver detalle endpoint #5)
2. Borrar `SessionController.java`, `SessionRepositoryAdapter.java`,
   `SessionJpaEntity.java`, `SessionJpaRepository.java`,
   `RegisterSessionUseCase.java`, `SessionInputDTO.java`,
   `WorkoutSession.java` (domain entity), `SessionRepository.java`
   (domain port). Confirmar que el backend sigue compilando

### Día 4 — Refactor compute engine integration

Ver detalle endpoint #13. Refactor `PythonComputeAdapter` y
`FatigueController` para que las métricas científicas se calculen
correctamente.

---

## Cambios a este documento

| Fecha | Cambio |
|---|---|
| 2026-05-04 | Versión inicial — auditoría completa de 18 endpoints contra backend Java en `:8000` |
