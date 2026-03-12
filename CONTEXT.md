# Shared Stack Context

This file is committed and loaded into every agent session. Keep it
generic — no secrets, no machine-specific paths. Machine-specific
details go in CONTEXT.local.md (gitignored).

## Stack

- **Backend**: Ruby on Rails (Rails 8), PostgreSQL
- **Frontend/Mobile**: React Native
- **Systems/Services**: Go
- **Cloud**: GCP (Cloud Run, Cloud SQL, Pub/Sub, GKE)
- **CI/CD**: GitHub Actions, Linear for ticket management
- **Load Testing**: k6
- **Containers**: Docker, docker-compose for local dev
- **ML**: Vertex AI Pipelines

## Conventions

- Ruby style: Sandi Metz / Avdi Grimm principles (POODR, Exceptional Ruby)
- Prefer POROs and actor-based service objects (`sunny/actor` gem) over fat models/controllers
- **TDD is mandatory** — nothing is written without tests first (red → green → refactor)
- RSpec for Rails testing, factory_bot with **deep composable traits** for fixtures
- Jest + React Native Testing Library for RN testing
- Table-driven tests in Go
- All PRs go through GitHub Actions CI before merge
- Linear for ticket tracking

## Agent Behavior Rules (apply to all agents)

1. Stay in your domain. If a task is outside your specialty, say so and name the correct agent.
2. Always reference this CONTEXT.md for stack decisions.
3. Default to the conventions above unless CONTEXT.local.md overrides them.
4. When producing code, produce the full file or the full changed section — no ellipsis placeholders.
5. After completing a task, state what the next agent in the chain should handle (if applicable).
6. **TDD is non-negotiable.** Test agents run before code agents. No implementation is written without failing tests first.
7. **Always use factories for test data.** Never hand-build objects or use raw `create`/`new` with inline attributes when a factory (with traits) can express the same thing. Only skip factories if there's a compelling, documented reason.
