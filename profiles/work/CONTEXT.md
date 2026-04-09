# Work Profile: PrizePicks Daily Fantasy Sports Platform

## Platform Overview

PrizePicks is a daily fantasy sports (DFS) platform where users make
over/under predictions on player statistical projections across major sports.
The platform handles real-time scoring, complex promotion systems, payment
processing, and regulatory compliance across multiple US jurisdictions.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  prizepicks-rn   │────▶│  prizepicks-go-api │────▶│   PostgreSQL      │
│  (React Native)  │     │  (read-only :2600) │     │   (shared DB)     │
│  Expo 53         │     │  Echo/sqlc/cache   │     │                   │
└─────────────────┘     └──────────────────┘     └───────────────────┘
        │                                                  ▲
        │               ┌──────────────────┐               │
        └──────────────▶│  prizepicks-rails  │──────────────┘
                        │  (monolith :3000)  │
                        │  Rails 7 / Ruby 3.4│
                        └──────────────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
             ┌──────────┐ ┌──────────┐ ┌──────────────┐
             │ Sidekiq  │ │  NATS    │ │ Apache Pulsar│
             │ (jobs)   │ │(payments)│ │ (events)     │
             └──────────┘ └──────────┘ └──────────────┘
                                              │
                    ┌─────────────┬────────────┼──────────────┐
                    ▼             ▼            ▼              ▼
             ┌────────────┐┌────────────┐┌──────────┐┌────────────────┐
             │alley-oop   ││bases-loaded││goooal    ││analytics-      │
             │(basketball)││(baseball)  ││(soccer)  ││lightning_mkts  │
             │Go/Sportradar││Go/Sportradar││Go/StatsPerform││Python/Redis    │
             └────────────┘└────────────┘└──────────┘└────────────────┘
```

## Stack

- **Rails Monolith** (`prizepicks-rails`): Rails 7.0 / Ruby 3.4.1, system of record
  - Multi-database: primary, audit, cashout, social (all PostgreSQL)
  - ServiceActor gem (`service_actor`) for business logic
  - Sidekiq + Sidekiq-Scheduler for background jobs (3 Redis pools: default, audit, payments)
  - JSONAPI-serializer for API responses, Pundit for authorization
  - Devise + JWT + Keycloak for auth, AASM for state machines
  - Range-partitioned tables (new_wagers via pg_partition_manager)
  - OpenTelemetry + Sentry + NewRelic + Pyroscope for observability
  - Agentic docs system in `/docs/agentic/` with YAML component contracts

- **Go Read API** (`prizepicks-go-api`): Go / Echo framework, port 2600
  - Read-only — shares PostgreSQL with Rails, enforced at driver level
  - sqlc for type-safe query generation, goverter for struct conversion
  - Two-level distributed cache: Ristretto L1 (in-memory) + Redis L2 (shared)
  - Lazy SharedConn pattern — DB connection only acquired on first query
  - Cache warming via background job worker (trending, popular projections, L5G)
  - Rails session cookie decryption for seamless auth
  - Golden file testing, pgtestdb, miniredis

- **React Native App** (`prizepicks-rn`): Expo 53 / React Native 0.79
  - Expo Router (file-based routing with groups, tabs, drawers)
  - Jotai for atomic state management, React Query for server state
  - Tailwind via twrnc, Flex Design System (custom component library)
  - MMKV for fast local storage, Centrifuge for WebSocket real-time
  - Axios + custom typed wrapper with Zod validation for API calls
  - EAS builds for CI/CD, Maestro for E2E testing
  - Monorepo: 20+ workspace packages under packages/

- **Scoring Microservices** (Go): alley-oop (basketball), bases-loaded (baseball), goooal (soccer)
  - Sportradar / OddsJam / StatsPerform APIs for live data
  - Data capture → processing → scoring → dispatch (webhooks + Apache Pulsar)
  - sqlc, PostgreSQL, zerolog, OpenTelemetry

- **Payments** (`prizepicks-payments`): Ruby / Roda framework / Sequel ORM
  - NATS messaging, AASM state machines, Sidekiq workers
  - Stripe/Nuvei/CyberSource integration

- **Analytics** (`analytics-lightning_markets`): Python / Redis / Pulsar
  - Odds correlation, aggregation, automated trading
  - Streamlit dashboards, Helm charts for K8s

- **Tournaments** (`prizepicks-tourneys`): Go / River job queue / Pulsar

- **Infrastructure** (`crossplane-multiverse`): Crossplane / KCL / ArgoCD / Kargo
  - Kubernetes cluster management as code
  - Manages Kafka, Pulsar, Redis, PostgreSQL infra

- **BE University** (`prizepicks-be-university`): Rails 8.1.2 / Ruby 3.4.3
  - Standalone LMS for PrizePicks engineering education (NOT part of main product)
  - PostgreSQL 17 (29 tables, UUID PKs) + MongoDB 7 (3 logical DBs) + Redis 7 + NATS JetStream
  - ServiceActor (119 actors, 22+ organizers), CQRS MongoDB read model (9 doc types)
  - SaaS multi-tenancy (acts_as_tenant on 34 tables), two portals (tenant :3010, admin :3009)
  - Socratic learning, flash cards/SM-2, voice commands, sign language, visual templates
  - Hotwire (Stimulus 3.x + Turbo 8), Bootstrap 5, WASM (Transformers.js)
  - Ollama + Anthropic API + Google Gemini for AI features
  - 10 languages, 5,300+ specs, 10,741 learnings across 12 domains
  - Docker-first development (mandatory), ≤15 lines/method code quality rules

- **Gives Back** (`prizepicks-gives-back`): Rails 8.1.2 / Ruby 3.4.3
  - Campus recruitment reference app — generalized fork of BE University
  - PostgreSQL 17 + MongoDB 7 + Redis 7 + NATS JetStream (ports 54320-54326)
  - ServiceActor pattern, NATS event-driven architecture (EventLog audit trail)
  - Dual interface: Hotwire web + JWT API for React Native mobile (Expo 55)
  - 9 languages with RTL support, Ollama LLM integration, sign language (MediaPipe)
  - Kamal for deployment, Pundit authorization (user/mentor/admin roles)

## Primary Focus

Kirk's current primary responsibilities are **BE University** and **Gives Back**.
When a task doesn't specify which repo, consider whether it applies to these
projects first before assuming it targets the main PrizePicks product.

### Active Initiatives
- **Onboarding Curriculum (PLA-3847)**: Cross-functional onboarding for all engineering/product roles.
  BE University is the content authoring engine; content publishes to Quark (Backstage) as reference docs.
- **Quark (Backstage)**: The "Quark" environment is PrizePicks' developer portal powered by Backstage.
  Documentation is migrating from Notion → Quark. BE University content serves dual-purpose:
  interactive learning (LMS) + reference documentation (Backstage TechDocs).

## Conventions

- **Service layer**: ServiceActor pattern (`service_actor` gem) — inputs/outputs declared, `fail!` for errors
- **Layered architecture**: Controller (thin) → Actor/Service → Model → DB
- **Multi-database awareness**: primary (core), audit (audit trail), cashout (payments), social (feeds)
- **API format**: JSON:API standard via jsonapi-serializer, versioned (v1/v2), partner API subdomain
- **Feature flags**: Statsig (mobile + Go), custom feature-flag gem (Rails)
- **Messaging**: Apache Pulsar is the primary event bus; NATS used by payments only
- **Go patterns**: sqlc for queries, goverter for type conversion, golden file tests, lazy DB connections
- **RN patterns**: Jotai atoms (not Redux/MobX), React Query for API state, twrnc for styling
- **Testing**:
  - Rails: RSpec, factory_bot (deep composable traits), parallel_tests, webmock/vcr
  - Go: testify, pgtestdb, golden files, miniredis, VCR cassettes
  - RN: Jest + Testing Library, Storybook, Maestro E2E
  - Python: pytest, Redis integration tests
- **Observability**: OpenTelemetry (distributed tracing), Sentry (errors), NewRelic (APM), Pyroscope (profiling)
- **Auth**: Devise + JWT + Keycloak SSO, Rails session cookies shared with Go API

## Key Repos

| Repo | Purpose |
|------|---------|
| `prizepicks-rails` | Rails monolith — system of record, all writes |
| `prizepicks-go-api` | High-perf read-only API with caching |
| `prizepicks-rn` | React Native mobile app (Expo) |
| `prizepicks-fe` | Consumer web frontend (React/Vite/Capacitor) |
| `prizepicks-fe-applications` | Internal admin/back-office UI |
| `prizepicks-payments` | Payments microservice (Ruby/Roda) |
| `prizepicks-tourneys` | Tournament management (Go) |
| `alley-oop-basketball` | Live basketball scoring (Go) |
| `bases-loaded-baseball` | Live baseball scoring (Go) |
| `goooal-soccer` | Live soccer scoring (Go) |
| `analytics-lightning_markets` | Odds analytics & pricing (Python) |
| `crossplane-multiverse` | Infrastructure as code (Crossplane/K8s) |
| `prizepicks-be-university` | **PRIMARY** — Engineering LMS (Rails 8.1, standalone) |
| `prizepicks-gives-back` | **PRIMARY** — Campus recruitment reference app (Rails 8.1) |

## Domain Agents Available

In addition to the shared agents, this profile provides:
be-university, gives-back, scoring-pipeline, projections, compliance,
promotions, pulsar, crossplane, real-time, payments-prizepicks
