const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8787;
const TASKS_PATH = path.join(__dirname, '..', '.clawdbot', 'active-tasks.json');
const INDEX_PATH = path.join(__dirname, 'index.html');

function readTasks() {
  try {
    const raw = fs.readFileSync(TASKS_PATH, 'utf-8');
    return JSON.parse(raw);
  } catch (e) {
    return [];
  }
}

const server = http.createServer((req, res) => {
  if (req.url === '/' || req.url.startsWith('/index.html')) {
    const html = fs.readFileSync(INDEX_PATH, 'utf-8');
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    return res.end(html);
  }

  if (req.url === '/api/tasks') {
    const tasks = readTasks();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ updatedAt: Date.now(), tasks }));
  }

  if (req.url === '/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive'
    });

    const send = () => {
      const tasks = readTasks();
      res.write(`data: ${JSON.stringify({ updatedAt: Date.now(), tasks })}\n\n`);
    };

    const interval = setInterval(send, 2000);
    send();

    req.on('close', () => clearInterval(interval));
    return;
  }

  res.writeHead(404);
  res.end('Not Found');
});

server.listen(PORT, () => {
  console.log(`Swarm dashboard running: http://localhost:${PORT}`);
});
