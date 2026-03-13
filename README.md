# Claude Agents

A profile-aware multi-agent system for Claude CLI. One repo, two environments — your work machine gets PrizePicks DFS agents, your home machine gets horse racing ML agents, and both share the same core language/testing/infra agents.

## Quick Start

```bash
# Clone the repo
git clone <repo-url> ~/dev/claude-agents
cd ~/dev/claude-agents

# Tell the sniffer which machine this is
echo "work" > .machine-profile   # work machine
# or
echo "home" > .machine-profile   # home machine

# Run an agent
./scripts/run-agent.sh rails
./scripts/run-agent.sh projections "Design cache warming for a new stat type"

# See what's available
./scripts/run-agent.sh
```

## How It Works

The `run-agent.sh` script detects which environment you're on and assembles a system prompt from three layers:

```
Shared CONTEXT.md          (TDD rules, universal conventions)
  + Profile CONTEXT.md     (stack-specific: PrizePicks or horse racing)
  + Agent .md              (specialist system prompt)
  = System prompt passed to Claude CLI
```

Agents live in two places:
- `agents/` — shared agents available in all profiles (ruby, rails, go, rspec, etc.)
- `profiles/<name>/agents/` — environment-specific agents

If a profile agent and a shared agent have the same name, the profile agent wins.

## Setting Up: Work Machine

Your work machine targets the PrizePicks platform. Primary focus is on BE University (engineering LMS) and Gives Back (campus recruitment app), with access to the full platform agents.

```bash
echo "work" > .machine-profile
```

This gives you 28 agents:

| Category | Agents |
|----------|--------|
| **Primary Projects** | be-university, gives-back |
| **Languages** | ruby, rails, golang, python, javascript, react-native |
| **Testing** | rspec, jest, go-test, pytest, integration |
| **Infrastructure** | postgres, docker, cicd, crossplane |
| **PrizePicks Domain** | projections, scoring-pipeline, real-time, compliance, promotions, payments-prizepicks, pulsar |
| **Cross-cutting** | security, api-design, docs, orchestrator |

The work profile CONTEXT.md provides PrizePicks-specific conventions to all agents:
- ServiceActor pattern, Sidekiq, multi-database (primary/audit/cashout/social)
- Go API patterns (sqlc, two-level cache, lazy SharedConn)
- React Native patterns (Jotai, Expo Router, twrnc, React Query)
- Repo map linking all PrizePicks repositories

## Setting Up: Home Machine

Your home machine targets the horse racing handicapping platform (Rails 8 + ML pipelines + CQRS).

```bash
echo "home" > .machine-profile
```

This gives you 31 agents:

| Category | Agents |
|----------|--------|
| **Languages** | ruby, rails, golang, python, javascript, react-native |
| **Testing** | rspec, jest, go-test, pytest, integration |
| **Infrastructure** | postgres, docker, cicd, gcp, k6 |
| **Data** | mongodb, cqrs, nats |
| **ML** | ml-planning, ml-orchestration, ml-pipeline |
| **Horse Racing** | handicapping, betting-strategy, horse-assessment, scraping |
| **Cross-cutting** | security, api-design, docs, payments, orchestrator |

The home profile CONTEXT.md provides horse racing conventions:
- Sunny::Actor, Solid Queue/Cache/Cable, MongoDB CQRS read store
- NATS JetStream, ONNX cross-platform inference, Vertex AI Pipelines

## Profile Detection

The sniffer in `run-agent.sh` tries these in order (first match wins):

| Priority | Method | Example |
|----------|--------|---------|
| 1 | `CLAUDE_AGENTS_PROFILE` env var | `CLAUDE_AGENTS_PROFILE=home ./scripts/run-agent.sh rails` |
| 2 | `.machine-profile` file | Contains `work` or `home` |
| 3 | Hostname | `linux-kkeeter*` → work |
| 4 | Directory probe | `~/dev/prizepicks` exists → work |

The `.machine-profile` file is gitignored, so each machine maintains its own identity. The env var override lets you cross-profile when needed (e.g., work on the horse racing project from your work machine).

## Repo Structure

```
├── CONTEXT.md                        # Shared conventions (TDD, agent behavior rules)
├── .machine-profile                  # "work" or "home" (gitignored)
├── agents/                           # Shared agents
│   ├── orchestrator.md               # Profile-aware task router
│   ├── ruby.md, rails.md, ...        # Language agents
│   ├── rspec.md, jest.md, ...        # Test agents
│   └── handoff-schema.json           # Orchestrator output format
├── profiles/
│   ├── work/
│   │   ├── CONTEXT.md                # PrizePicks stack & conventions
│   │   └── agents/                   # 8 PrizePicks domain agents
│   └── home/
│       ├── CONTEXT.md                # Horse racing stack & conventions
│       └── agents/                   # 13 horse racing / ML agents
└── scripts/
    └── run-agent.sh                  # Sniffer + agent runner
```

## Usage

```bash
# Interactive session with an agent
./scripts/run-agent.sh rails

# Pass an initial prompt
./scripts/run-agent.sh rspec "Write specs for the ProjectionSettlement actor"

# Override profile for a single run
CLAUDE_AGENTS_PROFILE=home ./scripts/run-agent.sh ml-pipeline

# List available agents for current profile
./scripts/run-agent.sh
```

## Adding a New Profile

1. Create `profiles/<name>/CONTEXT.md` with your stack details
2. Create `profiles/<name>/agents/` with domain-specific agents
3. Add hostname or directory detection to `run-agent.sh` (or just use `.machine-profile`)
4. Update the orchestrator's agent table in `agents/orchestrator.md`

## TDD Workflow

All profiles enforce the same TDD workflow:

```
test agent (write failing specs)
    → code agent (make them pass)
    → test agent (verify green)
```

The orchestrator enforces this. No code agent runs without a test agent first.

## Local Overrides

For machine-specific tweaks that shouldn't be committed (paths, secrets, personal preferences), create `CONTEXT.local.md` at the repo root. It's gitignored and layered after the profile context.
