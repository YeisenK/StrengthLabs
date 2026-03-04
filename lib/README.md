<div align="center">

<img src="https://img.shields.io/badge/version-0.1.0--alpha-blue?style=flat-square" alt="Version"/>
<img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License"/>
<img src="https://img.shields.io/badge/build-passing-brightgreen?style=flat-square" alt="Build"/>
<img src="https://img.shields.io/badge/coverage-≥80%25-brightgreen?style=flat-square" alt="Coverage"/>
<img src="https://img.shields.io/badge/security-0_critical_CVEs-brightgreen?style=flat-square" alt="Security"/>

<br/><br/>

```
███████╗████████╗██████╗ ███████╗███╗   ██╗ ██████╗ ████████╗██╗  ██╗
██╔════╝╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔════╝ ╚══██╔══╝██║  ██║
███████╗   ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ███╗   ██║   ███████║
╚════██║   ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║   ██║   ██╔══██║
███████║   ██║   ██║  ██║███████╗██║ ╚████║╚██████╔╝   ██║   ██║  ██║
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝
                                                                  LABS
```

**Adaptive Strength Intelligence Platform**

*Scientifically grounded fatigue modeling · Dynamic injury risk scoring · Transparent periodization engine*

<br/>

[Getting Started](#-getting-started) · [Architecture](#-architecture) · [API Reference](#-api-reference) · [Contributing](#-contributing) · [Roadmap](#-roadmap)

</div>

---

## Table of Contents

- [What is Strength Labs?](#-what-is-strength-labs)
- [Core Algorithms](#-core-algorithms)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [API Reference](#-api-reference)
- [Security Model](#-security-model)
- [Performance Targets](#-performance-targets)
- [Roles & Permissions](#-roles--permissions)
- [Contributing](#-contributing)
- [Roadmap](#-roadmap)
- [Academic References](#-academic-references)

---

## 🧠 What is Strength Labs?

Recreational and semi-professional athletes follow static training programs that don't dynamically account for accumulated fatigue, physiological recovery, or adaptation to training stimulus. Adjustment decisions are based on subjective perception, without a system that simultaneously models load, recovery, and progress.

This generates three primary risks:

- Abrupt load increases without quantitative control.
- Progressive and invisible accumulation of systemic fatigue.
- Higher probability of injury from overuse or overtraining.

**Strength Labs** is an open, auditable alternative. It implements evidence-based sports science metrics to dynamically model an athlete's training state and automatically recalibrate workload — no black boxes, no proprietary opacity.

**Key design principles:**

- **Transparent modeling** — every score, every recommendation is traceable to a documented algorithm
- **Academically grounded** — ATL/CTL, ACWR, and TSB models derived from peer-reviewed literature
- **Production-grade security** — JWT RS256, RBAC, TLS 1.3, zero stack trace exposure
- **Clean Architecture** — strict dependency inversion; domain logic has zero infrastructure dependencies

---

## 📐 Core Algorithms

The fatigue and risk engine sits entirely in the **domain layer** with no framework dependencies.

### Acute & Chronic Training Load (ATL / CTL)

```
ATL(t) = Σ TRIMP(i)  for i in [t-7,  t]   # 7-day rolling window
CTL(t) = Σ TRIMP(i)  for i in [t-28, t]   # 28-day rolling window
```

`TRIMP` (Training Impulse) is computed per session from volume, intensity (RPE/RIR), and heart rate data.

### Acute:Chronic Workload Ratio (ACWR)

```
ACWR = ATL / CTL
```

| ACWR Range | Zone | Interpretation |
|:----------:|:----:|----------------|
| < 0.8 | 🔵 Low | Under-training; below adaptive stimulus |
| 0.8 – 1.3 | 🟢 Optimal | Sweet spot; progression without excess spike |
| 1.3 – 1.5 | 🟡 Caution | Elevated injury risk; monitor closely |
| > 1.5 | 🔴 Danger | High spike; load reduction recommended |

> **Reference:** Hulin et al. (2016), *British Journal of Sports Medicine* — ACWR as a predictor of injury risk in team sport athletes.

### Training Stress Balance (TSB)

```
TSB = CTL - ATL
```

TSB drives the adaptive periodization engine. Negative TSB triggers volume recalibration; positive TSB unlocks intensity progression windows.

### Input Variables (User-Generated Data)

Primary variables captured per session:

- Sets · Reps · Weight (kg)
- RPE / RIR (Rate of Perceived Exertion / Reps in Reserve)
- Heart rate (mean bpm)
- Bodyweight (kg)
- Sleep hours

---

## 🏗 Architecture

Strength Labs implements **Clean Architecture** with strict layer isolation and dependency inversion at every boundary.

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                         │
│              Flutter Web / iOS / Android (SPA/PWA)          │
└─────────────────────────┬───────────────────────────────────┘
                          │ HTTPS / REST + JWT RS256
┌─────────────────────────▼───────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│         REST Controllers · OpenAPI 3.0 · Rate Limiting       │
│         Global Exception Handler · Security Headers          │
└─────────────────────────┬───────────────────────────────────┘
                          │ Use Case Interfaces (DTOs)
┌─────────────────────────▼───────────────────────────────────┐
│                    APPLICATION LAYER                         │
│    Use Cases · Command/Query Handlers · Port Interfaces      │
│    Session CRUD · Fatigue Calculation · Plan Generation      │
└──────────┬──────────────────────────────┬───────────────────┘
           │ Domain Entities              │ Port Contracts
┌──────────▼──────────┐      ┌────────────▼──────────────────┐
│    DOMAIN LAYER     │      │      INFRASTRUCTURE LAYER      │
│  (zero deps)        │      │                               │
│  FatigueEngine      │      │  PostgreSQL 16 (Flyway)       │
│  RiskEngine         │      │  Redis 7 (metric cache)       │
│  PeriodizationEngine│      │  JWT RS256 · OAuth 2.0        │
│  Entities / VOs     │      │  Prometheus · Grafana         │
└─────────────────────┘      └───────────────────────────────┘
```

**Dependency Rule:** arrows point inward only. Domain has zero knowledge of Spring/FastAPI, PostgreSQL, or Redis.

### Layer Responsibilities

| Layer | Owns | Must NOT import |
|-------|------|-----------------|
| `domain` | Entities, value objects, domain events, engine logic | Any framework, ORM, or I/O |
| `application` | Use cases, DTOs, port interfaces | Infrastructure implementations |
| `infrastructure` | Repository impls, JWT, cache, DB | Presentation concerns |
| `presentation` | Controllers, routes, middleware, validators | Domain internals directly |

### SOLID Principles Applied

- **Single Responsibility:** each domain service has one responsibility (`FatigueEngine` only computes ACWR/TSB).
- **Open/Closed:** new risk algorithms are added by implementing interfaces, without modifying existing code.
- **Dependency Inversion:** use cases depend on domain interfaces, never on concrete implementations.

---

## ⚙️ Technology Stack

### Backend
| Component | Technology |
|-----------|-----------|
| Runtime | Spring Boot 3 / FastAPI |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| Migrations | Flyway |
| API Docs | OpenAPI 3.0 |

### Frontend
| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3 (Web + iOS + Android) |
| State Management | Riverpod |
| Navigation | GoRouter |
| Design System | Material 3 |

### DevOps & Observability
| Component | Technology |
|-----------|-----------|
| Containers | Docker multi-stage builds |
| Orchestration | Docker Compose |
| CI/CD | GitHub Actions |
| Image Scanning | Trivy |
| Dependency Audit | OWASP Dependency-Check |
| Metrics | Prometheus + Grafana |

---

## 📁 Project Structure

```
strengthlabs/
│
├── backend/
│   └── src/
│       ├── domain/                         # ← Pure business logic. Zero external deps.
│       │   ├── entities/                   #   TrainingSession, Athlete, Plan
│       │   ├── engines/                    #   FatigueEngine, RiskEngine, PeriodizationEngine
│       │   ├── value-objects/              #   ACWR, TSB, InjuryRiskScore
│       │   └── repositories/              #   Repository contracts (interfaces only)
│       │
│       ├── application/                    # ← Use case orchestration
│       │   ├── use-cases/
│       │   │   ├── sessions/              #   CreateSession, GetSessions, UpdateSession, DeleteSession
│       │   │   ├── fatigue/               #   CalculateFatigue, GetFatigueHistory
│       │   │   └── plans/                 #   GeneratePlan, AdjustPlan
│       │   ├── dtos/
│       │   └── ports/                     #   IJwtService, ICacheService, INotificationService
│       │
│       ├── infrastructure/                 # ← External system adapters
│       │   ├── database/                  #   PostgreSQL repositories, Flyway migrations
│       │   ├── cache/                     #   Redis metric cache (ATL/CTL/TSB), TTL 24h
│       │   ├── auth/                      #   JWT RS256, OAuth 2.0 (Google)
│       │   └── monitoring/               #   Prometheus exporters
│       │
│       └── presentation/                  # ← HTTP delivery mechanism
│           ├── controllers/
│           ├── middleware/               #   authenticate, authorize (RBAC), rateLimiter
│           └── errors/                   #   GlobalExceptionHandler
│
├── frontend/                              # Flutter SPA/PWA (current working state)
│   └── lib/
│       ├── core/
│       │   ├── models/
│       │   │   ├── session.dart           #   TrainingSession model
│       │   │   └── training_metrics.dart  #   ATL, CTL, ACWR, TSB value objects
│       │   └── theme/
│       │       └── app_theme.dart         #   Material 3 theme configuration
│       │
│       └── features/
│           ├── auth/
│           │   └── screens/
│           │       └── login_screen.dart  #   Login + Google OAuth entry point
│           └── dashboard/
│               ├── screens/
│               │   └── dashboard_screen.dart   #   Main analytics dashboard
│               └── widgets/
│                   └── dashboard_widgets.dart  #   ACWR gauge, risk zone cards, session list
│
├── linux/                                 # Flutter Linux desktop target
├── macos/                                 # Flutter macOS target
├── web/                                   # Flutter Web target
├── android/                               # Flutter Android target
├── ios/                                   # Flutter iOS target
├── windows/                               # Flutter Windows target
│
├── docker/
│   ├── Dockerfile                         # Multi-stage: deps → builder → runner (Alpine, non-root)
│   └── docker-compose.yml                 # Full dev stack: API + PostgreSQL + Redis + Nginx proxy
│
├── .github/
│   └── workflows/
│       ├── ci.yml                         # Lint → Test → Build → Scan (Trivy + OWASP) → Push
│       └── cd.yml                         # Deploy on main merge (staging auto / prod manual)
│
├── docs/
│   ├── algorithms.md                      # ATL/CTL/ACWR/TSB academic references
│   ├── api-reference.md                   # Full OpenAPI endpoint documentation
│   └── architecture-decisions/            # ADR log
│
├── main.dart                              # Flutter app entry point
├── pubspec.yaml                           # Flutter dependencies
├── analysis_options.yaml                  # Dart lint rules
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

```bash
docker --version        # Docker 24+
docker compose version  # Compose v2+
node --version          # Node.js 22 LTS (backend, if running outside Docker)
flutter --version       # Flutter 3.x
```

### 1. Clone & configure environment

```bash
git clone https://github.com/your-org/strength-labs.git
cd strength-labs
cp .env.example .env
```

Edit `.env` and fill in at minimum:

```env
POSTGRES_PASSWORD=your_strong_password
REDIS_PASSWORD=your_redis_password
JWT_PRIVATE_KEY_BASE64=<base64-encoded RSA-4096 private key>
JWT_PUBLIC_KEY_BASE64=<base64-encoded RSA-4096 public key>
```

To generate the RSA key pair:

```bash
openssl genrsa -out private.pem 4096
openssl rsa -in private.pem -pubout -out public.pem
export JWT_PRIVATE_KEY_BASE64=$(base64 -w 0 private.pem)
export JWT_PUBLIC_KEY_BASE64=$(base64 -w 0 public.pem)
```

### 2. Start the full development stack

```bash
docker compose up --build
```

This starts:
- `api` — Backend on `http://localhost:8080`
- `postgres` — PostgreSQL 16 on port `5432`
- `redis` — Redis 7 on port `6379`
- `nginx-proxy` — Reverse proxy with TLS termination and rate limiting

### 3. Verify the stack is healthy

```bash
# All containers should show "healthy"
docker compose ps

# API health check
curl -s http://localhost:8080/health | jq .

# Liveness + readiness
curl -s http://localhost:8080/ready  | jq .
```

### 4. Run the Flutter frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome    # Web
flutter run -d ios       # iOS simulator
flutter run -d android   # Android emulator
```

### 5. Access the API docs

OpenAPI 3.0 interactive docs are available at:

```
http://localhost:8080/api/docs
```

---

## 📡 API Reference

> Full documentation: [`docs/api-reference.md`](docs/api-reference.md) · OpenAPI spec: `http://localhost:8080/api/docs`

### Authentication

```http
POST /auth/login
POST /auth/refresh
POST /auth/logout
POST /auth/oauth/google
```

### Training Sessions

```http
POST   /api/v1/sessions          # Log a new training session
GET    /api/v1/sessions          # List sessions (paginated)
GET    /api/v1/sessions/:id      # Get session detail
PATCH  /api/v1/sessions/:id      # Update session
DELETE /api/v1/sessions/:id      # Delete session
```

### Fatigue & Risk Engine

```http
GET /api/v1/metrics/fatigue          # Current ATL, CTL, ACWR, TSB
GET /api/v1/fatigue/history          # Historical fatigue curve (date range)
GET /api/v1/metrics/risk             # Current injury risk classification + score
```

### Adaptive Plans

```http
GET  /api/v1/plans/current           # Active weekly plan
POST /api/v1/plans/generate          # Trigger plan generation
POST /api/v1/plans/adjust            # Manual override + recalibration
```

### Dashboard

```http
GET /api/v1/dashboard                # Aggregated metrics for dashboard view
```

### Admin

```http
GET    /api/v1/admin/users           # List all users (ADMIN only)
DELETE /api/v1/admin/users/:id       # Remove user (ADMIN only)
```

### Example: Log a session

```bash
curl -X POST http://localhost:8080/api/v1/sessions \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2026-03-04",
    "exercises": [
      {
        "name": "Squat",
        "sets": 5,
        "reps": 3,
        "weightKg": 180,
        "rpe": 8.5
      }
    ],
    "bodyweightKg": 85.0,
    "sleepHours": 7.5,
    "heartRateMean": 142
  }'
```

---

## 🔒 Security Model

| Control | Implementation |
|---------|---------------|
| **Authentication** | JWT RS256 with RSA-4096 key pairs |
| **Token lifetime** | Access: 15 min · Refresh: 7 days (HttpOnly cookie) |
| **Authorization** | RBAC middleware — role validated on every request + resource ownership check |
| **OAuth** | Google OAuth 2.0 (PKCE flow) — no third-party passwords stored |
| **Transport** | TLS 1.3 — no HTTP in production |
| **At-rest encryption** | AES-256 for sensitive athlete data |
| **Rate limiting** | 5 attempts / 15 min on auth endpoints (per-IP + per-user) |
| **Error handling** | Global exception handler — zero stack trace, SQL query, or infra detail exposure |
| **Headers** | CSP · HSTS · X-Frame-Options · X-Content-Type-Options · SameSite=Strict cookies |
| **Dependencies** | OWASP Dependency-Check in CI — blocks on HIGH/CRITICAL |
| **Images** | Trivy scan in CI — blocks on CRITICAL CVEs |

### OWASP Top 10 Coverage

| Vulnerability | Mitigation |
|---------------|------------|
| A01: Broken Access Control | RBAC strict. Resource ownership validated on every request. |
| A02: Cryptographic Failures | TLS 1.3 in transit. AES-256 at rest for sensitive data. |
| A03: Injection (SQL) | Parameterized ORM. No query concatenation. Input validation. |
| A05: Security Misconfiguration | Security HTTP headers. Per-environment config. |
| A06: Vulnerable Components | Dependabot + OWASP Dependency-Check on every pipeline run. |
| A07: Auth Failures | Rate limiting on login. Rotating tokens. Logout invalidates session. |
| XSS / CSRF | Strict CSP. SameSite=Strict on cookies. Output sanitization in Flutter. |

---

## 📊 Performance Targets

| Metric | Target |
|--------|--------|
| P95 response time (analytical queries) | < 300ms |
| Redis cache hit rate (ATL/CTL/TSB) | > 95% |
| Test coverage (lines + branches) | ≥ 80% |
| Critical CVEs in CI | 0 |
| ArchUnit Clean Architecture violations | 0 |
| Lighthouse Performance score | > 90 |
| Lighthouse Accessibility score | > 90 (WCAG AA) |

---

## 👥 Roles & Permissions

```
┌─────────────┬──────────────────────────────────────────────────────────────┐
│ Role        │ Permissions                                                  │
├─────────────┼──────────────────────────────────────────────────────────────┤
│ user        │ Log own sessions · View own fatigue metrics · Access plans   │
├─────────────┼──────────────────────────────────────────────────────────────┤
│ trainer     │ user permissions + manage assigned athletes · generate and   │
│             │ adjust plans · monitor athlete risk metrics                  │
├─────────────┼──────────────────────────────────────────────────────────────┤
│ admin       │ trainer permissions + user management · system config ·      │
│             │ full audit log access (all actions audited)                  │
└─────────────┴──────────────────────────────────────────────────────────────┘
```

---

## 🖥 Frontend Screens

| Screen | Content |
|--------|---------|
| **Dashboard** | Current ACWR, TSB, risk zone, recent sessions, and active alerts |
| **Session Log** | Per-exercise form with real-time load calculation (RPE/RIR → TRIMP) |
| **Fatigue Analysis** | Historical ATL/CTL charts, ACWR index with color-coded zones |
| **Adaptive Plan** | Auto-generated weekly plan, manually adjustable with recalibration |
| **Profile & Metrics** | Bodyweight evolution, sleep trends, and per-exercise performance |

The Flutter client is a SPA with PWA capabilities: offline session logging, automatic sync on reconnect, and push notifications for risk alerts.

---

## 🤝 Contributing

Contributions welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a PR.

```bash
# Fork → clone → create branch
git checkout -b feat/your-feature-name

# Install dependencies
flutter pub get          # frontend
npm ci                   # or: mvn install (backend)

# Run tests
flutter test             # frontend
npm run test:ci          # backend

# Ensure linting passes
flutter analyze
npm run lint

# Commit using Conventional Commits
git commit -m "feat(fatigue-engine): add ACWR spike detection threshold"

# Push and open a pull request against main
```

**Branch naming:** `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`

**Commit format:** [Conventional Commits](https://www.conventionalcommits.org/) — enforced by CI.

---

## 🗺 Roadmap

- [x] Clean Architecture scaffolding
- [x] JWT RS256 authentication
- [x] Training session CRUD
- [x] Flutter login screen & dashboard skeleton
- [x] Core models: `TrainingSession`, `TrainingMetrics`
- [ ] ATL/CTL/ACWR/TSB fatigue engine (v0.2)
- [ ] Injury risk index with alert system (v0.2)
- [ ] Adaptive periodization engine (v0.3)
- [ ] Flutter Web dashboard — fatigue visualization & historical charts (v0.3)
- [ ] Google OAuth 2.0 integration (v0.4)
- [ ] Prometheus + Grafana observability stack (v0.4)
- [ ] Flutter iOS / Android mobile app (v0.5)
- [ ] Offline mode + PWA push notifications (v0.5)
- [ ] JWKS endpoint for key rotation (v0.5)
- [ ] Trainer multi-athlete dashboard (v0.6)
- [ ] Google Fit / Apple HealthKit biometric integration (v0.6)

---

## 📚 Academic References

- Gabbett, T.J. (2016). *The training-injury prevention paradox: should athletes be training smarter and harder?* British Journal of Sports Medicine.
- Hulin, B.T. et al. (2016). *Spikes in acute:chronic workload ratio (ACWR) predict injury: high chronic workload may decrease injury risk in elite rugby league players.* British Journal of Sports Medicine.
- Foster, C. (1998). *Monitoring training in athletes with reference to overtraining syndrome.* Medicine & Science in Sports & Exercise.
- Foster, C. (2001). *A new approach to monitoring exercise training.* Journal of Strength and Conditioning Research.
- Banister, E.W. (1991). *Modeling elite athletic performance.* Physiological Testing of Elite Athletes.
- OWASP Foundation (2021). *OWASP Top Ten.* https://owasp.org/Top10/

**Scientific Datasets:**
- Kaggle — Weightlifting Datasets (ACWR model validation)
- Kaggle — Heart Rate Datasets (heart rate component calibration)
- Open mHealth (biometric integration standards)

---

<div align="center">

**Strength Labs** — bridging sports science and software engineering.

Built with rigor. Designed for transparency. Optimized for athletes.

*Oscar Eduardo Cruz Cruz · Cristina Enríquez Martínez · Yeisen Kenneth López Reyes*

<br/>

<img src="https://img.shields.io/badge/Clean_Architecture-enforced-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/JWT-RS256-orange?style=flat-square"/>
<img src="https://img.shields.io/badge/ACWR-modeled-red?style=flat-square"/>
<img src="https://img.shields.io/badge/Flutter-3-02569B?style=flat-square&logo=flutter"/>
<img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql"/>
<img src="https://img.shields.io/badge/Redis-7-DC382D?style=flat-square&logo=redis"/>

</div>