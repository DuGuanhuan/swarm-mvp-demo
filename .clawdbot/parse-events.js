#!/usr/bin/env node
const fs = require('fs');
const readline = require('readline');

const args = process.argv.slice(2);
const getArg = (k) => {
  const idx = args.indexOf(k);
  return idx >= 0 ? args[idx + 1] : null;
};

const agent = getArg('--agent') || 'unknown';
const outPath = getArg('--out') || '.clawdbot/events.jsonl';
const logPath = getArg('--log') || null;

const outStream = fs.createWriteStream(outPath, { flags: 'a' });
const logStream = logPath ? fs.createWriteStream(logPath, { flags: 'a' }) : null;

let lastThinkTs = 0;
const THINK_THROTTLE_MS = 10000;

function emit(type, detail, raw) {
  const ts = new Date().toISOString();
  outStream.write(JSON.stringify({ ts, agent, type, detail, raw }) + '\n');
}

function parseLine(line) {
  const raw = line.trimEnd();
  if (logStream) logStream.write(raw + '\n');

  if (!raw) return;

  if (/Reading .*file/i.test(raw)) return emit('read', raw, raw);
  if (/Bash\(/i.test(raw) || /\bRunning\b.*Bash/i.test(raw)) return emit('bash', raw, raw);
  if (/write|edited|create file/i.test(raw)) return emit('write', raw, raw);
  if (/git commit/i.test(raw)) return emit('git', raw, raw);
  if (/push|opened PR|open PR/i.test(raw)) return emit('pr', raw, raw);
  if (/Ideating|thinking|Bootstrapping/i.test(raw)) {
    const now = Date.now();
    if (now - lastThinkTs > THINK_THROTTLE_MS) {
      lastThinkTs = now;
      return emit('think', raw, raw);
    }
  }
}

const rl = readline.createInterface({ input: process.stdin });
rl.on('line', parseLine);
rl.on('close', () => { outStream.end(); if (logStream) logStream.end(); });
