#!/usr/bin/env bash
set -euo pipefail

TASKS_FILE=".clawdbot/active-tasks.json"
DEFAULT_REPO="DuGuanhuan/swarm-mvp-demo"

if [ ! -f "$TASKS_FILE" ]; then
  echo "No tasks file found: $TASKS_FILE"
  exit 0
fi

for bin in jq gh tmux; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "$bin is required for check-agents.sh"
    exit 1
  fi
done

# Update task status based on tmux + PR/CI checks
UPDATED=$(jq -c '.' "$TASKS_FILE")

UPDATED=$(echo "$UPDATED" | jq -c --arg defaultRepo "$DEFAULT_REPO" '
  map(
    .repo = (.repo // $defaultRepo)
  )
')

# Iterate tasks in bash for tmux/gh checks
TMP=$(mktemp)
echo "$UPDATED" > "$TMP"

NEW_TASKS=()

while IFS= read -r row; do
  id=$(echo "$row" | jq -r '.id')
  status=$(echo "$row" | jq -r '.status')
  tmuxSession=$(echo "$row" | jq -r '.tmuxSession // empty')
  branch=$(echo "$row" | jq -r '.branch')
  repo=$(echo "$row" | jq -r '.repo')

  # tmux alive?
  tmuxAlive=true
  if [ -n "$tmuxSession" ]; then
    if ! tmux has-session -t "$tmuxSession" 2>/dev/null; then
      tmuxAlive=false
    fi
  fi

  # PR info
  prJson=$(gh pr list --repo "$repo" --head "$branch" --json number,url,state 2>/dev/null | jq '.[0] // empty')
  prNumber=$(echo "$prJson" | jq -r '.number // empty')
  prUrl=$(echo "$prJson" | jq -r '.url // empty')
  prState=$(echo "$prJson" | jq -r '.state // empty')

  # CI checks
  checksState=""
  if [ -n "$prNumber" ]; then
    # If any check fails, mark as failed. If all pass, mark as passed.
    if gh pr checks "$prNumber" --repo "$repo" >/tmp/gh_checks_$id.txt 2>/dev/null; then
      if grep -qi "fail" /tmp/gh_checks_$id.txt; then
        checksState="failed"
      elif grep -qi "pass\|success" /tmp/gh_checks_$id.txt; then
        checksState="passed"
      fi
    fi
  fi

  # Update status
  if [ "$status" = "running" ] && [ "$tmuxAlive" = "false" ]; then
    status="stopped"
  fi

  if [ -n "$prNumber" ]; then
    if [ "$checksState" = "passed" ]; then
      status="ready"
    elif [ "$checksState" = "failed" ]; then
      status="blocked"
    else
      # keep existing status
      status="$status"
    fi
  fi

  updatedRow=$(echo "$row" | jq --arg status "$status" --arg prNumber "$prNumber" --arg prUrl "$prUrl" --arg prState "$prState" --arg checksState "$checksState" '
    .status=$status
    | .prNumber=($prNumber|if .=="" then null else (.|tonumber) end)
    | .prUrl=($prUrl|if .=="" then null else . end)
    | .prState=($prState|if .=="" then null else . end)
    | .checksState=($checksState|if .=="" then null else . end)
  ')

  NEW_TASKS+=("$updatedRow")

done < <(jq -c '.[]' "$TMP")

printf '%s\n' "[" > "$TASKS_FILE"
for i in "${!NEW_TASKS[@]}"; do
  if [ "$i" -gt 0 ]; then
    printf ',\n' >> "$TASKS_FILE"
  fi
  printf '%s' "${NEW_TASKS[$i]}" >> "$TASKS_FILE"

done
printf '\n]\n' >> "$TASKS_FILE"

# Print summary
jq -r '.[] | "\(.id)\t\(.status)\t\(.branch)\t\(.worktree)\tPR:\(.prNumber // "-")\tCI:\(.checksState // "-")"' "$TASKS_FILE" || true

rm -f "$TMP" /tmp/gh_checks_*.txt || true
