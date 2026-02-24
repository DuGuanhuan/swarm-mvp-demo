#!/usr/bin/env bash
set -euo pipefail

AGENT="claude"
OUT="/Users/airr/Developer/playground/swarm-mvp-demo/.clawdbot/events.jsonl"
LOG="/Users/airr/Developer/playground/swarm-mvp-demo/.clawdbot/agent-logs/claude.log"

claude "$@" 2>&1 | node /Users/airr/Developer/playground/swarm-mvp-demo/.clawdbot/parse-events.js --agent "$AGENT" --out "$OUT" --log "$LOG"
