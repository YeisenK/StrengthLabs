# Strength Labs

Aplicación móvil para el registro, seguimiento y análisis de entrenamientos físicos.
---

## Descripción

Strength Labs es un MVP de aplicación móvil (iOS y Android) orientada a usuarios de gimnasio de todos los niveles. Permite registrar sesiones de entrenamiento con ejercicios, series, repeticiones, peso y RPE; consultar el historial completo con filtros por fecha y grupo muscular; calcular la fatiga y detectar sobreentrenamiento mediante un motor de lógica basado en RPE y volumen semanal; acceder a rutinas predeterminadas adaptadas al nivel y objetivo del usuario; y exportar los datos en formato Excel (.xlsx) y CSV.

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Frontend móvil | Flutter 3.x (iOS & Android) |
| Backend API | Python 3.11 + FastAPI |
| Base de datos | PostgreSQL 16 |
| ORM | SQLAlchemy 2.x + Alembic |
| Autenticación | JWT (python-jose + bcrypt) |
| Servidor | VPS Ubuntu 22.04 + Nginx + Gunicorn |
| Exportación | openpyxl / csv |

---

## Estructura del repositorio

```
strength-labs/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── routers/
│   │   ├── services/
│   │   └── core/
│   ├── alembic/
│   ├── tests/
│   ├── requirements.txt
│   ├── .env.example
│   └── Dockerfile
│
└── mobile/
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── core/
    │   ├── features/
    │   └── shared/
    ├── assets/
    └── pubspec.yaml
```

---

## Requisitos previos

Backend: Python 3.11+, PostgreSQL 16, pip.

Mobile: Flutter 3.x SDK, Android Studio o Xcode según la plataforma.

---

## Instalación local

### Backend

```bash
git clone https://github.com/tu-usuario/strength-labs.git
cd strength-labs/backend

python -m venv venv
source venv/bin/activate

pip install -r requirements.txt

cp .env.example .env
# Editar .env con las credenciales correspondientes

alembic upgrade head

uvicorn app.main:app --reload
```

La API estará disponible en `http://localhost:8000`.
Documentación interactiva en `http://localhost:8000/docs`.

### Mobile

```bash
cd strength-labs/mobile
flutter pub get
flutter run
```

Por defecto la app apunta a `http://10.0.2.2:8000` (loopback del emulador de Android al host). Para correr contra un backend distinto (LAN, device físico, staging), pasá la URL al arrancar:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8000
```

Para iOS simulator el default sirve si el backend está en `localhost`. Para un dispositivo físico usá la IP LAN del host.

---

## Variables de entorno

Crea un archivo `.env` en `backend/` con el siguiente contenido:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/strengthlabs_dev
SECRET_KEY=tu_clave_secreta_muy_larga_y_aleatoria
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=7
```

---

## Endpoints principales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/auth/register` | Registro de usuario |
| POST | `/auth/login` | Login y obtención de JWT |
| GET | `/workouts` | Historial de sesiones |
| POST | `/workouts` | Nueva sesión de entrenamiento |
| GET | `/fatigue/summary` | Índice de fatiga y alerta |
| GET | `/routines` | Rutinas sugeridas |
| GET | `/export/xlsx` | Exportar historial a Excel |
| GET | `/export/csv` | Exportar historial a CSV |

Documentación completa disponible en `/docs` (Swagger) y `/redoc`.

---

## Despliegue en VPS

```bash
git pull origin main
alembic upgrade head
systemctl restart strengthlabs-api

# Verificar logs
journalctl -u strengthlabs-api -f
```

---

## Arquitectura

Ver el documento completo en `docs/arquitectura.tex`.

---

## Roadmap

- [x] MVP — Registro de entrenamientos y cálculo de fatiga
- [ ] v1.1 — Notificaciones push (FCM)
- [ ] v1.2 — Generación dinámica de rutinas con IA
- [ ] v1.3 — Integración con Apple Health / Google Fit
- [ ] v2.0 — Panel de administración web

---

## Licencia

Uso interno. Todos los derechos reservados.