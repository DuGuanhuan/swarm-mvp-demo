#!/usr/bin/env bash
set -euo pipefail

TASKS_FILE=".clawdbot/active-tasks.json"

if [ ! -f "$TASKS_FILE" ]; then
  echo "No tasks file found: $TASKS_FILE"
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for check-agents.sh"
  exit 1
fi

# For now, just list active tasks (skeleton for future logic)
jq -r '.[] | "\(.id)\t\(.status)\t\(.branch)\t\(.worktree)"' "$TASKS_FILE" || true
