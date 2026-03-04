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

**Adaptive Training Intelligence Platform**

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

---

## 🧠 What is Strength Labs?

Most training platforms apply static programs that ignore the physiological reality of accumulated fatigue, recovery debt, and adaptive capacity. Manual adjustments remain largely subjective and unquantified.

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

| ACWR Range | Zone   | Interpretation                              |
|:----------:|:------:|---------------------------------------------|
| < 0.8      | 🔵 Low  | Under-training; below adaptive stimulus     |
| 0.8 – 1.3  | 🟢 Optimal | Sweet spot; progression without excess spike |
| 1.3 – 1.5  | 🟡 Caution | Elevated injury risk; monitor closely       |
| > 1.5      | 🔴 Danger | High spike; load reduction recommended      |

> **Reference:** Hulin et al. (2016), *British Journal of Sports Medicine* — ACWR as a predictor of injury risk in team sport athletes.

### Training Stress Balance (TSB)

```
TSB = CTL - ATL
```

TSB drives the adaptive periodization engine. Negative TSB triggers volume recalibration; positive TSB unlocks intensity progression windows.

---

## 🏗 Architecture

Strength Labs implements **Clean Architecture** with strict layer isolation and dependency inversion at every boundary.

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                         │
│              Flutter Web / iOS / Android (SPA)              │
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
│  Fatigue Engine     │      │  PostgreSQL 16 (Flyway)       │
│  Risk Engine        │      │  Redis 7 (metric cache)       │
│  Periodization      │      │  JWT RS256 · OAuth 2.0        │
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
strength-labs/
│
├── backend/
│   └── src/
│       ├── domain/                   # ← Pure business logic. Zero external deps.
│       │   ├── entities/             #   TrainingSession, Athlete, Plan
│       │   ├── engines/              #   FatigueEngine, RiskEngine, PeriodizationEngine
│       │   ├── value-objects/        #   ACWR, TSB, InjuryRiskScore
│       │   └── repositories/         #   Repository contracts (interfaces only)
│       │
│       ├── application/              # ← Use case orchestration
│       │   ├── use-cases/
│       │   │   ├── sessions/         #   CreateSession, GetSessions, UpdateSession, DeleteSession
│       │   │   ├── fatigue/          #   CalculateFatigue, GetFatigueHistory
│       │   │   └── plans/            #   GeneratePlan, AdjustPlan
│       │   ├── dtos/
│       │   └── ports/                #   IJwtService, ICacheService, INotificationService
│       │
│       ├── infrastructure/           # ← External system adapters
│       │   ├── database/             #   PostgreSQL repositories, Flyway migrations
│       │   ├── cache/                #   Redis metric cache (ATL/CTL/TSB)
│       │   ├── auth/                 #   JWT RS256, OAuth 2.0 (Google)
│       │   └── monitoring/           #   Prometheus exporters
│       │
│       └── presentation/             # ← HTTP delivery mechanism
│           ├── controllers/
│           ├── middleware/           #   authenticate, authorize (RBAC), rateLimiter
│           └── errors/               #   GlobalExceptionHandler
│
├── frontend/
│   └── lib/
│       ├── features/                 # Feature-first structure (sessions, fatigue, plans)
│       ├── core/                     # Shared widgets, theme, routing
│       └── infrastructure/           # API client, local storage
│
├── docker/
│   ├── Dockerfile                    # Multi-stage: deps → builder → runner
│   └── docker-compose.yml            # Full dev stack (API + PostgreSQL + Redis)
│
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Lint → Test → Build → Scan → Push
│       └── cd.yml                    # Deploy on main merge
│
└── docs/
    ├── algorithms.md                 # ATL/CTL/ACWR/TSB academic references
    ├── api-reference.md              # Full OpenAPI endpoint documentation
    └── architecture-decisions/       # ADR log
```

---

## 🚀 Getting Started

### Prerequisites

```bash
docker --version        # Docker 24+
docker compose version  # Compose v2+
node --version          # Node.js 22 LTS (backend, if running outside Docker)
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
export JWT_PUBLIC_KEY_BASE64=$(base64  -w 0 public.pem)
```

### 2. Start the full development stack

```bash
docker compose up --build
```

This starts:
- `api` — Backend on `http://localhost:8080`
- `postgres` — PostgreSQL 16 on port `5432`
- `redis` — Redis 7 on port `6379`

### 3. Verify the stack is healthy

```bash
# All containers should show "healthy"
docker compose ps

# API health check
curl -s http://localhost:8080/health | jq .

# Liveness + readiness
curl -s http://localhost:8080/ready  | jq .
```

### 4. Access the API docs

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

### Fatigue Engine

```http
GET /api/v1/fatigue/current      # Current ATL, CTL, ACWR, TSB
GET /api/v1/fatigue/history      # Historical fatigue curve (date range)
GET /api/v1/fatigue/risk         # Current injury risk classification + score
```

### Adaptive Plans

```http
GET  /api/v1/plans/current       # Active weekly plan
POST /api/v1/plans/generate      # Trigger plan generation
POST /api/v1/plans/adjust        # Manual override + recalibration
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
| **Authorization** | RBAC middleware — role validated on every request |
| **OAuth** | Google OAuth 2.0 (PKCE flow) |
| **Transport** | TLS 1.3 — no HTTP in production |
| **At-rest encryption** | AES-256 for sensitive athlete data |
| **Rate limiting** | Per-IP + per-user on auth endpoints |
| **Error handling** | Global exception handler — zero stack trace exposure |
| **Headers** | CSP · HSTS · X-Frame-Options · X-Content-Type-Options |
| **Dependencies** | OWASP Dependency-Check in CI — blocks on HIGH/CRITICAL |
| **Images** | Trivy scan in CI — blocks on CRITICAL CVEs |

---

## 📊 Performance Targets

| Metric | Target |
|--------|--------|
| P95 response time (analytical queries) | < 300ms |
| Test coverage | ≥ 80% |
| Critical CVEs in CI | 0 |
| Lighthouse Performance score | > 90 |
| Lighthouse Accessibility score | > 90 |
| Redis cache hit rate (ATL/CTL) | > 95% |

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
│             │ full audit log access                                         │
└─────────────┴──────────────────────────────────────────────────────────────┘
```

---

## 🤝 Contributing

Contributions welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a PR.

```bash
# Fork → clone → create branch
git checkout -b feat/your-feature-name

# Install dependencies
npm ci   # or: mvn install

# Run tests
npm run test:ci

# Ensure linting passes
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
- [ ] ATL/CTL/ACWR/TSB fatigue engine (v0.2)
- [ ] Injury risk index with alert system (v0.2)
- [ ] Adaptive periodization engine (v0.3)
- [ ] Flutter Web dashboard — fatigue visualization (v0.3)
- [ ] Google OAuth 2.0 integration (v0.4)
- [ ] Prometheus + Grafana observability stack (v0.4)
- [ ] Flutter iOS / Android mobile app (v0.5)
- [ ] JWKS endpoint for key rotation (v0.5)
- [ ] Trainer multi-athlete dashboard (v0.6)

---

## 📚 Academic References

- Hulin, B. T., et al. (2016). *The acute:chronic workload ratio predicts injury: high chronic workload may decrease injury risk in elite rugby league players.* British Journal of Sports Medicine.
- Banister, E. W. (1991). *Modeling elite athletic performance.* Physiological Testing of Elite Athletes.
- Foster, C. (1998). *Monitoring training in athletes with reference to overtraining syndrome.* Medicine & Science in Sports & Exercise.

---

<div align="center">

**Strength Labs** — bridging sports science and software engineering.

Built with rigor. Designed for transparency. Optimized for athletes.

<br/>

<img src="https://img.shields.io/badge/Clean_Architecture-enforced-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/JWT-RS256-orange?style=flat-square"/>
<img src="https://img.shields.io/badge/ACWR-modeled-red?style=flat-square"/>
<img src="https://img.shields.io/badge/Flutter-3-02569B?style=flat-square&logo=flutter"/>
<img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql"/>
<img src="https://img.shields.io/badge/Redis-7-DC382D?style=flat-square&logo=redis"/>

</div>