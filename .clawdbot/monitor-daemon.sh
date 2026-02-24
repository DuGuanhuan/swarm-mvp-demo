#!/usr/bin/env bash
set -euo pipefail

LOG="/Users/airr/Developer/playground/swarm-mvp-demo/.clawdbot/monitor.log"
while true; do
  cd /Users/airr/Developer/playground/swarm-mvp-demo
  ./.clawdbot/check-agents.sh >> "$LOG" 2>&1
  sleep 5
done
