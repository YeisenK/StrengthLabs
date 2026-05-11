# StrengthLabs

Aplicación móvil multiplataforma (Android e iOS) para registro y análisis de entrenamientos de fuerza. Calcula métricas científicas de fatiga (ATL, CTL, TSB, ACWR), riesgo de lesión y genera planes de periodización basados en el estado real del atleta.

---

## Stack técnico

| Capa | Tecnología |
|---|---|
| Frontend móvil | Flutter 3.x · BLoC 9.x · go_router 17.x · Dio 5.x |
| Backend API | Java 21 · Spring Boot 4.0.x · Spring Security · Spring Data JPA |
| Compute engine | Python 3.12 · FastAPI · NumPy · SciPy |
| Base de datos | PostgreSQL 16 |
| Cache | Redis 7 |
| Auth | JWT RS256 · Google Sign-In |
| Exportación local | `excel` + `share_plus` (en dispositivo) |

> El backend vive en un repositorio separado: [`~/StrengthLabsBackend`](../StrengthLabsBackend/README.md).

---

## Repositorios

```
~/StrengthLabs/          ← este repo, frontend Flutter
~/StrengthLabsBackend/   ← backend Java + compute engine Python
```

---

## Estructura del frontend

```
lib/
├── features/
│   ├── auth/            ← login, register, Google Sign-In
│   ├── workouts/        ← CRUD + sesión activa con timer
│   ├── routines/        ← rutinas predefinidas
│   ├── fatigue/         ← dashboard ATL/CTL/TSB/ACWR/readiness
│   ├── plan/            ← plan semanal generado por compute engine
│   ├── export/          ← exportar historial a CSV/XLSX
│   └── settings/        ← cuenta, unidades, tema, idioma, logout
├── core/
│   ├── constants/       ← api_constants.dart, app_colors.dart
│   └── storage/         ← token_storage.dart (flutter_secure_storage)
├── shared/
│   └── widgets/         ← skeleton loaders, app_button, app_text_field
└── l10n/                ← strings EN/ES (app_en.arb, app_es.arb)
```

---

## Requisitos previos

- Flutter 3.x SDK (`flutter doctor`)
- Backend corriendo en `localhost:8000` (ver instrucciones en `~/StrengthLabsBackend/README.md`)

---

## Arrancar en local

### 1. Levantar el backend primero

```bash
# En ~/StrengthLabsBackend
docker compose -f docker/docker-compose.yml up postgres redis -d
DB_PASSWORD=changeme ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Compute engine (necesario para dashboard de fatiga)
cd recursos
uvicorn api.main:app --host 0.0.0.0 --port 8001 --reload
```

### 2. Arrancar el frontend

```bash
cd ~/StrengthLabs
flutter pub get
flutter run
```

La app se conecta a `http://10.0.2.2:8000` desde el emulador Android (loopback al host). Para device físico:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.X.X:8000
```

---

## Endpoints principales del backend

Documentación interactiva en `http://localhost:8000/swagger-ui/index.html`.

| Método | Endpoint | Descripción |
|---|---|---|
| POST | `/auth/register` | Registro con email/password |
| POST | `/auth/login` | Login → access + refresh token |
| POST | `/auth/refresh` | Renovar access token |
| POST | `/auth/google` | Login con Google (id_token) |
| GET | `/auth/me` | Datos del usuario autenticado |
| GET | `/workouts` | Historial con jerarquía exercises → sets |
| POST | `/workouts` | Crear sesión de entrenamiento |
| GET/PUT/DELETE | `/workouts/{id}` | Detalle, editar, borrar |
| GET | `/exercises` | Catálogo global + custom del usuario |
| POST | `/exercises` | Crear ejercicio custom |
| GET | `/routines` | Rutinas predefinidas (filtro: `?level=`) |
| GET | `/fatigue/summary` | 19 métricas: ATL, CTL, TSB, ACWR, readiness… |
| GET | `/export/csv` | Historial en CSV (server-side) |
| GET | `/export/xlsx` | Historial en Excel (server-side) |

---

## Idiomas

La app soporta inglés y español. Strings en `lib/l10n/app_en.arb` y `lib/l10n/app_es.arb`. El idioma del sistema se detecta automáticamente; el usuario puede cambiarlo en Settings.

---

## Estado del proyecto

Ver [`documentacion/FASES_IMPLEMENTACION.md`](documentacion/FASES_IMPLEMENTACION.md) para el plan de trabajo actual.

---

## Licencia

Uso interno. Todos los derechos reservados.
