# Checklist de sesión — StrengthLabs

Documento vivo que detalla qué hicimos, qué sigue, y qué decisiones están
pendientes. Se actualiza al final de cada bloque de trabajo.

Para el plan macro (todas las fases, decisiones arquitectónicas, glosario)
ver `PLAN.md`. Este documento es el "qué hago AHORA".

---

## Estado actual

**Fecha**: 2026-05-04
**Fase activa**: Fase 0 — Setup y verificación
**Progreso de Fase 0**: ~70%

### Hecho

#### Verificación de tooling
- Docker 29.4.0 + Compose v5.1.3
- JDK OpenJDK 21.0.10 (Red Hat)
- Maven Wrapper presente en `~/StrengthLabsBackend/mvnw`
- Python 3.14.3
- Flutter 3.41.4 stable

#### Sincronización del compute engine
- La versión "buena" del compute engine vivía en `~/StrengthLabs/backend/recursos/`
  (Yeisen la había evolucionado ahí); la del backend tenía versión vieja
  simplificada
- Copiada `~/StrengthLabs/backend/recursos/{api,domain}/` →
  `~/StrengthLabsBackend/recursos/`
- Tests del backend conservados en `recursos/tests/`
- Compute engine arranca con `uvicorn` y `/health` responde
- 3 tests fallan: están escritos para el modelo viejo. Marcado como deuda
  técnica para Fase 5

#### Limpieza
- `~/StrengthLabs/backend/` borrada (skeleton Python obsoleto)
- `~/StrengthLabs/.vscode/settings.json` borrado (ruta vieja `/home/void/`)
- `~/StrengthLabs/documentacion/Arquitectura(deprecated).pdf` borrada
- Verificado: cero referencias a `backend/` en `lib/` o `pubspec.yaml`

#### Arreglos al backend
- `docker-compose.yml` limpiado:
  - Quitado `version: '3.9'` obsoleto
  - Removido servicio `compute-engine` (path roto + mejor manual con
    uvicorn para hot reload)
  - Comentario explicando cómo correrlo en dev
- `.gitignore` agregado: `__pycache__/`, `*.pyc`, `*.pyo`, `.pytest_cache/`
- `.env` creado con `DB_PASSWORD=changeme` (en gitignore)

#### Infraestructura corriendo
- Postgres 16 en `:5432` (DB `strengthlabs`, user `stlabs`)
- Redis 7 en `:6379`

### Pendiente del Fase 0 (lo que sigue)

1. **Commits de seguridad** — ver "Bloque 1" abajo
2. **Aplicar `schema.sql` a Postgres** (provisional, lo reemplaza Fase 2)
3. **Arrancar backend Java** y verificar `/swagger-ui.html`
4. **Arrancar frontend** en modo demo y verificar las 5 tabs

### Decisiones pendientes en este momento

1. **¿Commits separados o todo de una?**
   - Recomendado: dos commits independientes (uno backend, uno frontend)
   - Esto permite revertir un repo sin tocar el otro

2. **¿Schema viejo o ya el nuevo?**
   - Recomendado: aplicar el viejo `schema.sql` ahora para verificar que el
     backend Java arranca tal como Yeisen lo dejó. El nuevo schema se
     redacta en Fase 2 con migración Flyway

3. **¿Aceptás los riesgos de arrancar el backend Java sin haber leído el
   `application.yml`?**
   - Posible que falte alguna config (Redis URL, etc.)
   - Lo más probable es que arranque pero algo de Redis o JWT haya que
     configurar

---

## Bloque 1 — Commits de seguridad (próximo paso)

**Por qué**: tenemos cambios significativos en ambos repos sin commitear. Si
algo del backend Java falla y necesitamos revertir, queremos un punto seguro.

### Backend (`~/StrengthLabsBackend/`)

**Cambios staged:**
- `docker/docker-compose.yml` modificado (limpieza)
- `.gitignore` modificado (Python ignores)
- `recursos/api/` actualizada con versión nueva del compute engine
- `recursos/api/schemas/plan_schema.py` nuevo
- `recursos/api/routers/{fatigue,plan,risk}.py` modificados
- `recursos/api/schemas/{fatigue,risk}_schema.py` modificados
- (`__pycache__` ahora ignorados)

**Commit propuesto:**
```
sync compute engine al modelo nuevo + cleanup docker

- Reemplaza recursos/api/ y recursos/domain/ con la versión más nueva
  que vivía en el repo del frontend
- Agrega plan_schema.py con validación Pydantic completa
- Quita servicio compute-engine del docker-compose (path roto + mejor
  correrlo manual con uvicorn en dev)
- Quita 'version: 3.9' obsoleto del compose
- Agrega ignores Python al .gitignore

Tests del compute engine fallan (3) — están escritos para el modelo
viejo. Deuda técnica para Fase 5 cuando refactor PythonComputeAdapter.
```

### Frontend (`~/StrengthLabs/`)

**Cambios staged:**
- `pubspec.lock` modificado (transitivas: characters 1.4.0→1.4.1, matcher
  0.12.17→0.12.19) — benigno
- `backend/` borrada entera (skeleton Python obsoleto)
- `.vscode/settings.json` borrado
- `documentacion/Arquitectura(deprecated).pdf` borrada
- `documentacion/PLAN.md` nuevo
- `documentacion/CHECKLIST.md` nuevo (este archivo)

**Commit propuesto:**
```
limpieza repo + plan de trabajo

- Borra ~/StrengthLabs/backend/ (skeleton Python obsoleto, el backend
  real es Java en repo separado StrengthLabsBackend/)
- Borra .vscode/settings.json con ruta vieja /home/void/
- Borra Arquitectura(deprecated).pdf
- Agrega PLAN.md con plan completo de trabajo (7 fases, decisiones
  arquitectónicas, trampas conocidas)
- Agrega CHECKLIST.md como documento vivo de progreso
```

---

## Bloque 2 — Aplicar schema.sql provisional

**Por qué**: el backend Java requiere las tablas existentes (`users`,
`training_sessions`, `training_metrics`) para arrancar sin errores de JPA.

**Comando:**
```bash
docker exec -i stlabs-postgres psql -U stlabs -d strengthlabs \
  < ~/StrengthLabsBackend/schema.sql
```

**Verificación:**
```bash
docker exec stlabs-postgres psql -U stlabs -d strengthlabs -c "\dt"
# Debe listar: users, training_sessions, training_metrics
```

**Nota**: este schema se reemplaza completo en Fase 2 con Flyway. Es
provisional para que el backend arranque ahora.

---

## Bloque 3 — Arrancar backend Java

**Por qué**: confirmar que la base que dejó Yeisen funciona antes de tocar
nada. Cualquier endpoint que ya esté implementado se ve en Swagger.

**Pasos:**

1. **Leer `application.yml` y `application-dev.yml`** para entender qué
   variables de entorno espera. Posibles candidatos:
   - `JWT_SECRET` (probable)
   - `compute-engine.url` (debe ser `http://localhost:8001`)
   - Redis URL
   - DB connection (debe leer del docker-compose)

2. **Exportar variables que falten:**
   ```bash
   export DB_PASSWORD=changeme
   export JWT_SECRET="dev-secret-key-must-be-at-least-32-chars-long"
   ```

3. **Arrancar:**
   ```bash
   cd ~/StrengthLabsBackend
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
   ```

4. **Verificar:**
   - Logs sin errores fatales
   - `curl http://localhost:8000/swagger-ui.html` (o `/swagger-ui/index.html`)
     devuelve HTML
   - `curl http://localhost:8000/v3/api-docs` devuelve JSON con los
     endpoints

**Riesgos conocidos:**
- Si `application.yml` apunta a una BD inexistente o variables faltantes,
  la app no arranca
- Si Hibernate `ddl-auto: validate` y el schema no coincide, falla
- Si `compute-engine.url` no está configurado, el bean falla a la creación
  pero Spring puede arrancar igual con `@Lazy`

**Plan B si falla:** leer logs, corregir config, reintentar. NO
hacer cambios al código aún — solo configuración.

---

## Bloque 4 — Arrancar frontend en modo demo

**Por qué**: confirmar que el frontend tal como está sigue funcionando.

**Pasos:**

```bash
cd ~/StrengthLabs
flutter pub get
flutter devices  # ver qué emuladores/devices hay disponibles
flutter run      # elegir device si hay más de uno
```

**Verificación**: te logueás con `example@example.com` / `example` y
navegás las 5 tabs (Workouts, Routines, Fatigue, Plan, Export). Cada una
muestra mock data sin errores.

**Riesgos conocidos:**
- Si no tenés emulador Android configurado, hay que crear uno o usar
  device físico
- `flutter pub get` puede modificar `pubspec.lock` (ya pasó: cambios
  benignos en transitivas)

---

## Bloque 5 (cierre del Fase 0) — Documentar lo encontrado

Después de los Bloques 1-4, actualizar `PLAN.md` y este `CHECKLIST.md` con:

- ¿Qué endpoints del backend Java realmente existen y funcionan?
  (lista del Swagger)
- ¿Qué shape devuelve cada uno?
- ¿Qué configuración hizo falta agregar?
- Screenshot del frontend andando (opcional, para tener evidencia)

Esto alimenta directamente el **Bloque inicial de Fase 1**: mapear el
contrato API real vs el esperado por el frontend.

---

## Después del Fase 0: Fase 1 (vista preliminar)

Cuando termine el Fase 0 (verificación del setup), arrancamos Fase 1:

**Objetivo de Fase 1**: producir `documentacion/api-contract.md` con la
tabla maestra de endpoints.

**Cómo trabajaremos**: voy a leer cada repositorio del frontend
(`lib/features/*/data/*_repository.dart`) y extraer:
- URL que llama
- Método HTTP
- Body que envía
- Shape que parsea de la respuesta

Después comparo con cada controller del backend y marco:
- ✓ alineado
- ⚠ existe pero shape distinto (con detalle)
- ❌ falta

El entregable de Fase 1 da el orden exacto de trabajo de las Fases 2-6.

---

## Cambios a este documento

| Fecha | Cambio |
|---|---|
| 2026-05-04 | Versión inicial — al cierre del bloque de sync/cleanup |
