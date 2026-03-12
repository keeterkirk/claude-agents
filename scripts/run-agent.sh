#!/usr/bin/env bash
# Usage: ./scripts/run-agent.sh <agent-name> [optional prompt]
# Example: ./scripts/run-agent.sh rails
# Example: ./scripts/run-agent.sh rspec "Write specs for the UserService class"

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$REPO_DIR/agents"
CONTEXT_FILE="$REPO_DIR/CONTEXT.md"
LOCAL_CONTEXT="$REPO_DIR/CONTEXT.local.md"

AGENT_NAME="${1:-}"

if [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: $0 <agent-name> [prompt]"
  echo ""
  echo "Available agents:"
  ls "$AGENTS_DIR"/*.md | xargs -I{} basename {} .md | sort
  exit 1
fi

AGENT_FILE="$AGENTS_DIR/${AGENT_NAME}.md"

if [[ ! -f "$AGENT_FILE" ]]; then
  echo "Error: Agent '$AGENT_NAME' not found at $AGENT_FILE"
  echo ""
  echo "Available agents:"
  ls "$AGENTS_DIR"/*.md | xargs -I{} basename {} .md | sort
  exit 1
fi

# Build the system prompt by concatenating context + agent prompt
SYSTEM_PROMPT="$(cat "$CONTEXT_FILE")"

if [[ -f "$LOCAL_CONTEXT" ]]; then
  SYSTEM_PROMPT="$SYSTEM_PROMPT

---

$(cat "$LOCAL_CONTEXT")"
fi

SYSTEM_PROMPT="$SYSTEM_PROMPT

---

$(cat "$AGENT_FILE")"

INITIAL_PROMPT="${2:-}"

if [[ -n "$INITIAL_PROMPT" ]]; then
  # Non-interactive: pass prompt directly
  echo "$INITIAL_PROMPT" | claude --system-prompt "$SYSTEM_PROMPT"
else
  # Interactive session
  claude --system-prompt "$SYSTEM_PROMPT"
fi
