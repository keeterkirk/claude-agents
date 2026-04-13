#!/usr/bin/env bash
# Usage: ./scripts/run-agent.sh <agent-name> [optional prompt]
# Example: ./scripts/run-agent.sh rails
# Example: ./scripts/run-agent.sh rspec "Write specs for the UserService class"
# Example: CLAUDE_AGENTS_PROFILE=home ./scripts/run-agent.sh ml-pipeline

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$REPO_DIR/agents"
PROFILES_DIR="$REPO_DIR/profiles"
CONTEXT_FILE="$REPO_DIR/CONTEXT.md"
LOCAL_CONTEXT="$REPO_DIR/CONTEXT.local.md"

# ─── Profile Detection (the "sniffer") ───────────────────────────────
detect_profile() {
  # 1. Explicit env var override (highest priority)
  if [[ -n "${CLAUDE_AGENTS_PROFILE:-}" ]]; then
    echo "$CLAUDE_AGENTS_PROFILE"
    return
  fi

  # 2. Machine-local dotfile (gitignored)
  local dotfile="$REPO_DIR/.machine-profile"
  if [[ -f "$dotfile" ]]; then
    head -1 "$dotfile" | tr -d '[:space:]'
    return
  fi

  # 3. Hostname-based detection
  local host
  host="$(hostname 2>/dev/null || echo "")"
  case "$host" in
    linux-kkeeter*) echo "work"; return ;;
    # Add home hostname pattern here, e.g.:
    # myhomemachine*) echo "home"; return ;;
  esac

  # 4. Directory-probe fallback
  if [[ -d "$HOME/dev/prizepicks" ]]; then
    echo "work"
    return
  fi

  # 5. No profile detected — use base agents only
  echo ""
}

PROFILE="$(detect_profile)"

# ─── Agent Resolution ─────────────────────────────────────────────────
# Profile agents override shared agents. Lookup order:
#   1. profiles/<profile>/agents/<name>.md  (profile-specific)
#   2. agents/<name>.md                      (shared/universal)

resolve_agent() {
  local name="$1"

  if [[ -n "$PROFILE" && -f "$PROFILES_DIR/$PROFILE/agents/${name}.md" ]]; then
    echo "$PROFILES_DIR/$PROFILE/agents/${name}.md"
    return
  fi

  if [[ -f "$AGENTS_DIR/${name}.md" ]]; then
    echo "$AGENTS_DIR/${name}.md"
    return
  fi

  echo ""
}

# ─── List Available Agents ────────────────────────────────────────────
list_agents() {
  local -A agents  # associative array for dedup

  # Shared agents
  for f in "$AGENTS_DIR"/*.md; do
    [[ -f "$f" ]] && agents["$(basename "$f" .md)"]=1
  done

  # Profile agents (add/override)
  if [[ -n "$PROFILE" && -d "$PROFILES_DIR/$PROFILE/agents" ]]; then
    for f in "$PROFILES_DIR/$PROFILE/agents"/*.md; do
      [[ -f "$f" ]] && agents["$(basename "$f" .md)"]=1
    done
  fi

  printf '%s\n' "${!agents[@]}" | sort
}

# ─── Argument Handling ────────────────────────────────────────────────
AGENT_NAME="${1:-}"

if [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: $0 <agent-name> [prompt]"
  if [[ -n "$PROFILE" ]]; then
    echo "Active profile: $PROFILE"
  else
    echo "Active profile: (none — shared agents only)"
  fi
  echo ""
  echo "Available agents:"
  list_agents
  exit 1
fi

AGENT_FILE="$(resolve_agent "$AGENT_NAME")"

if [[ -z "$AGENT_FILE" ]]; then
  echo "Error: Agent '$AGENT_NAME' not found."
  if [[ -n "$PROFILE" ]]; then
    echo "Active profile: $PROFILE"
  fi
  echo ""
  echo "Available agents:"
  list_agents
  exit 1
fi

# ─── Repo-Level Context Detection ─────────────────────────────────────
# Walk up from cwd looking for AGENTS.md in the repo root.
# This provides application-specific context for the current project.

detect_repo_context() {
  local dir
  dir="$(pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/AGENTS.md" && -d "$dir/.git" ]]; then
      echo "$dir/AGENTS.md"
      return
    fi
    dir="$(dirname "$dir")"
  done
  echo ""
}

REPO_CONTEXT="$(detect_repo_context)"

# ─── Build System Prompt ──────────────────────────────────────────────
# Layers (in order):
#   1. Shared CONTEXT.md         — universal conventions
#   2. Profile CONTEXT.md        — environment-specific stack details
#   3. Repo AGENTS.md            — application-specific context (auto-detected)
#   4. CONTEXT.local.md          — machine-specific overrides (gitignored)
#   5. Agent .md                 — the specialist's system prompt

SYSTEM_PROMPT="$(cat "$CONTEXT_FILE")"

# Layer in profile context
if [[ -n "$PROFILE" && -f "$PROFILES_DIR/$PROFILE/CONTEXT.md" ]]; then
  SYSTEM_PROMPT="$SYSTEM_PROMPT

---

$(cat "$PROFILES_DIR/$PROFILE/CONTEXT.md")"
fi

# Layer in repo-level context
if [[ -n "$REPO_CONTEXT" ]]; then
  SYSTEM_PROMPT="$SYSTEM_PROMPT

---

$(cat "$REPO_CONTEXT")"
fi

# Layer in local overrides
if [[ -f "$LOCAL_CONTEXT" ]]; then
  SYSTEM_PROMPT="$SYSTEM_PROMPT

---

$(cat "$LOCAL_CONTEXT")"
fi

# Layer in the agent prompt
SYSTEM_PROMPT="$SYSTEM_PROMPT

---

$(cat "$AGENT_FILE")"

# ─── Run Claude ───────────────────────────────────────────────────────
INITIAL_PROMPT="${2:-}"

if [[ -n "$PROFILE" ]]; then
  local_info="▸ Profile: $PROFILE  |  Agent: $AGENT_NAME  |  $(basename "$AGENT_FILE")"
  if [[ -n "$REPO_CONTEXT" ]]; then
    local_info="$local_info  |  Repo: $(dirname "$REPO_CONTEXT" | xargs basename)"
  fi
  echo "$local_info"
fi

if [[ -n "$INITIAL_PROMPT" ]]; then
  echo "$INITIAL_PROMPT" | claude --system-prompt "$SYSTEM_PROMPT"
else
  claude --system-prompt "$SYSTEM_PROMPT"
fi
