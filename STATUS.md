# Estado del proyecto — StrengthLabs (frontend)

**Última actualización**: 2026-05-10

---

## Arrancar en 5 comandos

```bash
# 1. Infraestructura (en ~/StrengthLabsBackend)
docker compose -f docker/docker-compose.yml up postgres redis -d

# 2. Backend Java (en ~/StrengthLabsBackend)
DB_PASSWORD=changeme ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# 3. Compute engine (en ~/StrengthLabsBackend/recursos, opcional)
uvicorn api.main:app --host 0.0.0.0 --port 8001 --reload

# 4. Frontend
cd ~/StrengthLabs && flutter pub get && flutter run
```

---

## Qué está implementado y funcionando

| Feature | Estado | Notas |
|---|---|---|
| Auth (email/password) | ✅ | Login, register, refresh, me |
| Auth (Google Sign-In) | ⚠️ | Frontend listo; falta `google-services.json` y Web Client ID real |
| Workouts CRUD | ✅ | Crear, listar, detalle, editar, borrar con UNDO |
| Active Workout | ✅ | Timer, agregar ejercicios con búsqueda y filtro, sets |
| Filtros historial | ✅ | Por fecha (DateRange) y muscle group |
| Routines | ✅ | 5 rutinas predefinidas, filtro por nivel |
| Fatigue dashboard | ✅ shape | Muestra datos reales si compute engine está arriba; 0s si no |
| Plan semanal | ✅ | Generado localmente en Dart desde métricas |
| Export CSV/XLSX | ✅ | En dispositivo con `excel` + `share_plus` |
| Settings | ✅ | Cuenta, kg/lb, tema, idioma, logout |
| i18n EN/ES | ✅ | 137 strings, detecta idioma del sistema |
| Skeleton loaders | ✅ | En workouts, routines, fatigue |
| Haptic feedback | ✅ | En set completado, fin de workout, borrar, exportar |

---

## Qué falta (resumen de fases)

| Fase | Descripción | Prioridad |
|---|---|---|
| **0** | Sync docs (este archivo) | En curso |
| **1** | Fix logout race condition, 503 en compute caído | 🔴 Alta |
| **3** | Cache de métricas (hoy recalcula siempre) | 🟠 Alta |
| **4** | Tests: 0 tests en frontend | 🟠 Alta |
| **5** | Rate limiting, logout blacklist backend | 🟠 Alta |
| **6** | Keystore release, Google Sign-In real, iconos, splash | 🟠 Alta |
| **7** | GitHub Actions CI | 🟡 Media |
| **8** | Onboarding, smart defaults, FCM, Apple Health | 🟢 Post-MVP |

Ver detalles en [`documentacion/FASES_IMPLEMENTACION.md`](documentacion/FASES_IMPLEMENTACION.md).

---

## Deuda técnica conocida

- `lib/features/auth/presentation/pages/login_page.dart` — credenciales demo precargadas (borrar o dejar solo en `kDebugMode`)
- `lib/core/constants/app_strings.dart` — archivo obsoleto, la app usa `AppLocalizations`; borrar en Fase 1
- Modo demo (`example@example.com`) activo en release — controlar con flag

---

## Versión y build

- Flutter: 3.41.4
- applicationId: `com.strengthlabs.app`
- versionName: `1.0.0` · versionCode: `1`
- Signing release: configurado en `build.gradle.kts`; falta `android/key.properties`
