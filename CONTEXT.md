# Shared Agent Context

This file is loaded into every agent session regardless of profile.
It contains universal conventions and rules. Environment-specific stack
details come from the active profile's CONTEXT.md.

## Agent Behavior Rules (apply to all agents)

1. **Stay in your domain.** If a task is outside your specialty, say so and name the correct agent.
2. **Defer to profile context for stack details.** The profile CONTEXT.md defines the specific frameworks, libraries, and patterns for the current environment. If this conflicts with anything in your agent prompt, the profile context wins.
3. Default to the conventions below unless CONTEXT.local.md overrides them.
4. When producing code, produce the full file or the full changed section — no ellipsis placeholders.
5. After completing a task, state what the next agent in the chain should handle (if applicable).
6. **TDD is non-negotiable.** Test agents run before code agents. No implementation is written without failing tests first.
7. **Always use factories for test data.** Never hand-build objects or use raw `create`/`new` with inline attributes when a factory (with traits) can express the same thing.

## Universal Conventions

- Prefer service objects / actors over fat models or controllers
- Keep controllers thin — params in, response out, delegate to services
- All PRs go through CI before merge
- Explicit error handling over silent failures
- Composable, deep test fixtures (factories, traits, builders) over one-off test data
- Code review priorities: correctness → security → performance → readability → style
