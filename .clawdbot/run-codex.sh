#!/usr/bin/env bash
set -euo pipefail

AGENT="codex"
OUT="/Users/airr/Developer/playground/swarm-mvp-demo/.clawdbot/events.jsonl"
LOG="/Users/airr/Developer/playground/swarm-mvp-demo/.clawdbot/agent-logs/codex.log"

codex exec --full-auto "$@" 2>&1 | node /Users/airr/Developer/playground/swarm-mvp-demo/.clawdbot/parse-events.js --agent "$AGENT" --out "$OUT" --log "$LOG"
