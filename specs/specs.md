# Project Specs Template

## Overview
- Product summary:
- Goals:
- Non-goals:

## Stack
- Backend:
- Database:
- Cache/Queue:
- Frontend:
- Infra:
- CI/CD:
- Notes: short rationale or constraints (e.g., hosting limits, legacy compatibility).

## Architecture
- Options (fill as needed):
  - Services/components:
  - Data stores:
  - External integrations:
  - Notes:

## Conventions
- Options (edit as needed):
  - Naming: PascalCase classes, camelCase vars, snake_case DB columns, kebab-case routes, SCREAMING_SNAKE envs.
  - Backend structure: `app/Actions`, `app/Http/Controllers`, `app/Http/Requests`, `app/Policies`, `app/Models`, `app/Enums`, `app/Rules`, `app/Services`, `app/Jobs`, `app/Events`, `app/Listeners`, `app/Notifications`, `app/Observers`, `app/Resources`, `app/Support`, `app/Integrations` (or `app/Libraries` when needed).
  - Frontend structure: `resources/js/pages`, `resources/js/components`, `resources/js/layouts`, `resources/js/hooks`, `resources/js/stores`, `resources/js/types`, `resources/js/lib`, `resources/js/styles`, `resources/js/routes` (if needed).
  - Code style: PSR-12, strict types when available, small single-purpose classes, avoid mixed responsibilities, prefer composition.
  - Testing: Pest (unit/feature), Playwright or Cypress for e2e.
  - Error handling: centralized exceptions, consistent error payloads, no stack traces to clients.
  - Logging: structured logs, correlation IDs, PII redaction.
  - Boosts: keep Laravel conventions, avoid hard-coded paths, first-party queues/cache/session, explicit env config.
  - Notes:

## Performance & Security
- Options (edit as needed):
  - SLOs/SLAs: latency targets for critical endpoints and jobs.
  - Rate limits: per-IP and per-user for auth and write operations.
  - Auth/AuthZ: session or token based, RBAC/ABAC as required, policy enforcement at boundaries.
  - Data sensitivity: classify PII/PHI/PCI, encrypt at rest/in transit, audit access.
  - Threats: OWASP Top 10, SQLi, XSS, CSRF, SSRF, IDOR, file upload abuse, path traversal, auth/session fixation, rate-limit bypass, secrets exposure, supply-chain risks, misconfigurations.
  - Perf checklist: DB indexes/query plans, cache hot paths, queue long tasks, CDN/static asset caching, connection pooling, optimize images/assets, eliminate N+1, reduce cold starts, monitor p95/p99.
  - Notes:

## Laravel Boosts
- Enable Boosts-friendly defaults: queue/cache/session drivers aligned to environment, explicit env config, no hard-coded paths.
- Note any deviations from Boosts conventions and why.

## UX/UI
- Options (edit as needed):
  - Design system:
  - Accessibility: WCAG 2.1 AA (or required standard)
  - Responsiveness: mobile-first, common breakpoints
  - Notes:

## Delivery
- Options (edit as needed):
  - Environments: dev, staging, production
  - Release: CI/CD with approvals and migrations
  - Rollback: database-safe rollback + deploy rollback
  - Notes:

## References
- Options (add links):
  - Docs/links:
  - Notes:
