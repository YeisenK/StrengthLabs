# Checklist de sesión — StrengthLabs

Documento vivo que detalla qué hicimos, qué sigue, y qué decisiones están
pendientes. Se actualiza al final de cada bloque de trabajo.

Para el plan macro: ver `PLAN.md`.
Para el cronograma día por día: ver `ROADMAP.md`.

---

## Estado actual

**Fecha**: 2026-05-04
**Última fase cerrada**: ✓ Fase 0 — Setup y verificación (100%)
**Próxima fase**: Día 1 — Mapeo del contrato API

---

## ✓ Fase 0 cerrada

### Tooling verificado
- Docker 29.4.0 + Compose v5.1.3
- JDK OpenJDK 21.0.10 (Red Hat)
- Maven Wrapper presente en `~/StrengthLabsBackend/mvnw`
- Python 3.14.3
- Flutter 3.41.4 stable

### Sincronización del compute engine
- Versión nueva (la que vivía en `~/StrengthLabs/backend/recursos/`) ahora
  está en `~/StrengthLabsBackend/recursos/`
- Tests del backend conservados, fallan con el modelo nuevo (deuda
  técnica para Día 4)
- Compute engine arranca con `uvicorn` y `/health` responde

### Limpieza ejecutada
- `~/StrengthLabs/backend/` borrada (skeleton Python obsoleto)
- `~/StrengthLabs/.vscode/settings.json` borrado
- `~/StrengthLabs/documentacion/Arquitectura(deprecated).pdf` borrada
- `docker-compose.yml` limpio (sin compute-engine roto, sin version
  obsoleta)
- `.gitignore` Python agregado al backend

### Backend Java funcionando ✓
- Arrancado en `:8000`
- Bug fix aplicado: `@EnableJpaRepositories` + `@EntityScan` (en Spring
  Boot 4 `EntityScan` se movió a
  `org.springframework.boot.persistence.autoconfigure`)
- Swagger UI carga en `/swagger-ui/index.html`
- Auth funciona: `POST /auth/register` devuelve 201 con JWT RS256
- Hibernate creó 6 tablas con modelo jerárquico
- Seeders OK: 62 ejercicios + 5 rutinas

### Frontend funcionando ✓
- Arranca con `flutter run`
- Modo demo OK
- Las 5 tabs cargan con mock data

### Infraestructura corriendo en background
- Postgres 16 en `:5432` (DB `strengthlabs`, user `stlabs`)
- Redis 7 en `:6379`
- Backend Java en `:8000`
- Compute engine: NO arrancado (levantar cuando se necesite)

### Documentos creados
- `documentacion/PLAN.md` — plan macro y decisiones arquitectónicas
- `documentacion/ROADMAP.md` — cronograma día por día (8 días)
- `documentacion/CHECKLIST.md` — este archivo

### Commits hechos
- Backend `566587f`: sync compute engine + cleanup docker
- Backend `efcb7c3`: fix Spring Boot 4 annotations
- Frontend `4661b51`: limpieza repo + plan de trabajo
- Frontend `23dab1e`: reescala ROADMAP de 17 a 8 días

---

## Sorpresa importante de Fase 0

Al arrancar el backend descubrimos que Yeisen ya implementó **mucho más
de lo asumido**. Casi todas las Fases 2-6 originales del PLAN ya están
en el backend:

- 9 controllers funcionando (Auth, Workout, Exercise, Routine, Fatigue,
  Export, Admin, Metrics + SessionController viejo a borrar)
- Modelo de datos jerárquico (User, Exercise, Workout,
  WorkoutExercise, WorkoutSet) ya en JPA entities
- Seeders con 62 ejercicios y 5 rutinas canónicas
- Auth completa con JWT RS256

Por eso el ROADMAP se reescaló a **8 días** en lugar de 17. Lo que
queda:
- Conectar frontend al backend real
- POST /auth/google
- Refactor PythonComputeAdapter al modelo nuevo
- Borrar SessionController viejo
- Frontend cleanup, i18n, filtros, pre-release

---

## Próximo paso: Día 1 — Mapeo del contrato API

**Objetivo**: documento `documentacion/api-contract.md` que confirma o
desmiente, endpoint por endpoint, si el shape del backend coincide con
lo que parsea el frontend.

**Cómo lo voy a hacer**:
1. Por cada endpoint que use el frontend, leer el repo
   correspondiente en `lib/features/*/data/*_repository.dart` para
   extraer:
   - Path
   - Body que envía
   - Shape que parsea
2. Hacer curl al backend y comparar response real vs shape esperado
3. Para los endpoints que ya probamos en Fase 0 (`register`, `login`,
   `me`, `exercises`, `workouts`, `routines`), confirmar
4. Para los que faltan probar (`refresh`, `POST /workouts`,
   `PUT /workouts/{id}`, `DELETE /workouts/{id}`, `fatigue/summary`,
   `fatigue/weekly`, etc.), hacer curl con datos válidos
5. Generar `api-contract.md` con tabla maestra:
   - ✓ alineado
   - ⚠ existe pero shape distinto (con detalle)
   - ❌ falta (sabemos solo `POST /auth/google`)
6. Para cada ⚠ y ❌, anotar acción concreta en columna "Acción"

**Tiempo estimado**: 2-4 horas (puedo avanzar bastante autónomo)

**Lo que necesito de vos**: nada inmediato, solo darme luz verde para
empezar. Backend ya está arriba, no hace falta que toques nada.

---

## Para parar/retomar la sesión

**Parar todo**:
```bash
pkill -f spring-boot:run
docker compose -f ~/StrengthLabsBackend/docker/docker-compose.yml down
```

**Retomar (en orden)**:
```bash
docker compose -f ~/StrengthLabsBackend/docker/docker-compose.yml up postgres redis -d
cd ~/StrengthLabsBackend
DB_PASSWORD=changeme ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
# en otra terminal si hace falta el compute:
cd ~/StrengthLabsBackend/recursos && uvicorn api.main:app --port 8001 --reload
# en otra terminal si trabajamos frontend:
cd ~/StrengthLabs && flutter run
```

---

## Cambios a este documento

| Fecha | Cambio |
|---|---|
| 2026-05-04 (mañana) | Versión inicial — al cierre del bloque de sync/cleanup |
| 2026-05-04 (tarde) | Fase 0 cerrada al 100%, próxima parada Día 1 |
