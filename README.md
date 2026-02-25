<h1>Strength Labs</h1>

<p>
Strength Labs is an adaptive training intelligence platform designed to dynamically model fatigue,
workload, recovery, and injury risk using scientifically backed metrics.
</p>

<p>
The system provides a transparent, auditable, and academically grounded alternative
to commercial black-box fitness solutions.
</p>

<hr/>

<h2>Overview</h2>

<p>
Athletes often follow static training programs that fail to account for accumulated fatigue,
physiological recovery, and adaptive progression. Manual adjustments are typically subjective
and lack quantitative modeling.
</p>

<p>Strength Labs addresses this problem by implementing:</p>

<ul>
  <li>Acute and chronic workload modeling (ATL / CTL)</li>
  <li>Acute:Chronic Workload Ratio (ACWR)</li>
  <li>Training Stress Balance (TSB)</li>
  <li>Dynamic injury risk scoring</li>
  <li>Adaptive periodization engine</li>
  <li>Secure, scalable backend architecture</li>
</ul>

<hr/>

<h2>Core Features</h2>

<h3>Training Session Management</h3>
<ul>
  <li>Full CRUD operations</li>
  <li>Exercise-level tracking:
    <ul>
      <li>Sets</li>
      <li>Repetitions</li>
      <li>Weight</li>
      <li>RPE / RIR</li>
      <li>Heart rate</li>
      <li>Bodyweight</li>
      <li>Sleep hours</li>
    </ul>
  </li>
</ul>

<h3>Fatigue Engine</h3>
<ul>
  <li>Acute Load (7-day rolling window)</li>
  <li>Chronic Load (28-day rolling window)</li>
  <li>ACWR calculation</li>
  <li>Training Stress Balance (TSB)</li>
  <li>Redis-based metric caching</li>
</ul>

<h3>Injury Risk Index</h3>
<ul>
  <li>Dynamic risk classification (Green / Yellow / Red)</li>
  <li>Workload spike detection</li>
  <li>Automated alert system</li>
</ul>

<h3>Adaptive Periodization</h3>
<ul>
  <li>Automatic weekly plan adjustments</li>
  <li>Volume and intensity recalibration</li>
  <li>TSB-driven recommendations</li>
</ul>

<h3>Dashboard Analytics</h3>
<ul>
  <li>Historical ATL/CTL visualization</li>
  <li>ACWR trend tracking</li>
  <li>Risk zone indicators</li>
  <li>Performance progression metrics</li>
</ul>

<hr/>

<h2>Architecture</h2>

<p>
Strength Labs implements <strong>Clean Architecture</strong> with strict dependency inversion.
</p>

<table border="1" cellpadding="8" cellspacing="0">
  <tr>
    <th>Layer</th>
    <th>Responsibility</th>
  </tr>
  <tr>
    <td>Domain</td>
    <td>Pure business logic (Fatigue Engine, Risk Engine, Periodization Engine)</td>
  </tr>
  <tr>
    <td>Application</td>
    <td>Use cases and orchestration</td>
  </tr>
  <tr>
    <td>Infrastructure</td>
    <td>Database, cache, external integrations</td>
  </tr>
  <tr>
    <td>Presentation</td>
    <td>REST controllers and API layer</td>
  </tr>
  <tr>
    <td>Client</td>
    <td>Flutter Web / Mobile SPA</td>
  </tr>
</table>

<hr/>

<h2>Technology Stack</h2>

<h3>Backend</h3>
<ul>
  <li>Spring Boot 3 or FastAPI</li>
  <li>PostgreSQL 16</li>
  <li>Redis 7</li>
  <li>Flyway migrations</li>
  <li>OpenAPI 3.0 documentation</li>
</ul>

<h3>Frontend</h3>
<ul>
  <li>Flutter 3 (Web + iOS + Android)</li>
  <li>Riverpod</li>
  <li>GoRouter</li>
  <li>Material 3</li>
</ul>

<h3>Security</h3>
<ul>
  <li>JWT (RS256)</li>
  <li>OAuth 2.0 (Google)</li>
  <li>RBAC</li>
  <li>TLS 1.3 encryption</li>
  <li>AES-256 encryption at rest</li>
  <li>OWASP Top 10 mitigation</li>
</ul>

<h3>DevOps</h3>
<ul>
  <li>Docker multi-stage builds</li>
  <li>Docker Compose</li>
  <li>GitHub Actions CI/CD</li>
  <li>Trivy image scanning</li>
  <li>OWASP Dependency-Check</li>
  <li>Prometheus + Grafana</li>
</ul>

<hr/>

<h2>Security Model</h2>

<ul>
  <li>Short-lived access tokens (15 minutes)</li>
  <li>HttpOnly refresh tokens</li>
  <li>Strict resource ownership validation</li>
  <li>Rate limiting on authentication endpoints</li>
  <li>Global exception handling (no stack trace exposure)</li>
  <li>Security headers (CSP, HSTS, X-Frame-Options)</li>
</ul>

<hr/>

<h2>Performance Targets</h2>

<ul>
  <li>&lt; 300ms response time (P95) for analytical queries</li>
  <li>&gt; 80% test coverage</li>
  <li>0 critical vulnerabilities in CI pipeline</li>
  <li>Lighthouse score &gt; 90 (Performance + Accessibility)</li>
</ul>

<hr/>

<h2>Roles</h2>

<h3>User</h3>
<ul>
  <li>Log sessions</li>
  <li>View fatigue metrics</li>
  <li>Access adaptive plans</li>
</ul>

<h3>Trainer</h3>
<ul>
  <li>Manage assigned athletes</li>
  <li>Generate and adjust plans</li>
  <li>Monitor risk metrics</li>
</ul>

<h3>Administrator</h3>
<ul>
  <li>User management</li>
  <li>System configuration</li>
  <li>Audit log access</li>
</ul>

<hr/>

<h2>Project Structure</h2>

<pre>
backend/
frontend/
docker/
.github/workflows/
docs/
</pre>

<hr/>

<h2>Vision</h2>

<p>
Strength Labs aims to bridge the gap between academic sports science
and practical athletic programming through transparent modeling,
secure architecture, and data-driven decision systems.
</p>