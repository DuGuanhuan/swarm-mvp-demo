#!/usr/bin/env bash
set -euo pipefail

TASKS_FILE="../.clawdbot/active-tasks.json"
OUT_FILE="./dashboard.html"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required"; exit 1
fi

DATA=$(jq -c '.' "$TASKS_FILE")

cat > "$OUT_FILE" <<HTML
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <title>Agent Swarm Dashboard</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; color:#222; }
    h1 { margin-bottom: 8px; }
    .meta { color:#666; margin-bottom: 16px; }
    table { width:100%; border-collapse: collapse; }
    th, td { border: 1px solid #e5e5e5; padding: 8px; text-align: left; }
    th { background:#f6f6f6; }
    .tag { display:inline-block; padding:2px 6px; border-radius:6px; font-size:12px; }
    .running { background:#e8f5e9; color:#2e7d32; }
    .ready { background:#e3f2fd; color:#1565c0; }
    .blocked { background:#fff3e0; color:#ef6c00; }
    .stopped { background:#ffebee; color:#c62828; }
    .muted { color:#888; font-size:12px; }
  </style>
</head>
<body>
  <h1>Swarm 任务看板</h1>
  <div class="meta">数据来源：.clawdbot/active-tasks.json（生成时间：<span id="ts"></span>）</div>
  <div class="meta muted">提示：页面每 30 秒自动刷新（需配合定时生成 HTML）</div>
  <table>
    <thead>
      <tr>
        <th>任务ID</th>
        <th>Agent</th>
        <th>状态</th>
        <th>分支</th>
        <th>工作区</th>
        <th>tmux</th>
        <th>PR</th>
        <th>CI</th>
      </tr>
    </thead>
    <tbody id="rows"></tbody>
  </table>

<script>
const data = $DATA;
const tbody = document.getElementById('rows');
const ts = document.getElementById('ts');
ts.textContent = new Date().toLocaleString();

// Auto-refresh page every 30s
setTimeout(() => location.reload(), 30000);

const statusClass = (s) => (s||'').toLowerCase();

(data || []).forEach(t => {
  const tr = document.createElement('tr');
  const status = t.status || '-';
  const statusTag = `<span class="tag ${statusClass(status)}">${status}</span>`;
  const pr = t.prUrl ? `<a href="${t.prUrl}" target="_blank">#${t.prNumber || ''}</a>` : '-';
  const ci = t.checksState || '-';

  tr.innerHTML = `
    <td>${t.id || '-'}</td>
    <td>${t.agent || '-'}</td>
    <td>${statusTag}</td>
    <td>${t.branch || '-'}</td>
    <td class="muted">${t.worktree || '-'}</td>
    <td>${t.tmuxSession || '-'}</td>
    <td>${pr}</td>
    <td>${ci}</td>
  `;
  tbody.appendChild(tr);
});
</script>
</body>
</html>
HTML

echo "Generated $OUT_FILE"
