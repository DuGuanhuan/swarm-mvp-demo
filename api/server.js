const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const dataDir = path.join(__dirname, '..', 'data');
const storePath = path.join(dataDir, 'store.json');
const seedPath = path.join(dataDir, 'seed.json');

app.use(express.json());

function ensureStoreExists() {
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }

  if (!fs.existsSync(storePath)) {
    if (fs.existsSync(seedPath)) {
      fs.copyFileSync(seedPath, storePath);
    } else {
      fs.writeFileSync(storePath, JSON.stringify({ sources: [], items: [] }, null, 2));
    }
  }
}

function readStore() {
  ensureStoreExists();
  const raw = fs.readFileSync(storePath, 'utf-8');
  const parsed = JSON.parse(raw);

  if (!Array.isArray(parsed.sources)) parsed.sources = [];
  if (!Array.isArray(parsed.items)) parsed.items = [];

  return parsed;
}

function writeStore(payload) {
  fs.writeFileSync(storePath, JSON.stringify(payload, null, 2));
}

function makeId(prefix) {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
}

app.post('/sources', (req, res) => {
  const { name, url } = req.body || {};

  if (!name || typeof name !== 'string') {
    return res.status(400).json({ error: 'Field "name" is required.' });
  }

  const store = readStore();
  const source = {
    id: makeId('src'),
    name,
    url: typeof url === 'string' ? url : null,
    createdAt: new Date().toISOString()
  };

  store.sources.push(source);
  writeStore(store);

  return res.status(201).json(source);
});

app.get('/sources', (_req, res) => {
  const store = readStore();
  return res.json({ count: store.sources.length, sources: store.sources });
});

app.post('/ingest', (req, res) => {
  const { sourceId, items } = req.body || {};

  if (!sourceId || typeof sourceId !== 'string') {
    return res.status(400).json({ error: 'Field "sourceId" is required.' });
  }

  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'Field "items" must be a non-empty array.' });
  }

  const store = readStore();

  const sourceExists = store.sources.some((source) => source.id === sourceId);
  if (!sourceExists) {
    return res.status(404).json({ error: 'Source not found.' });
  }

  const createdItems = items.map((item) => ({
    id: makeId('item'),
    sourceId,
    title: item && typeof item.title === 'string' ? item.title : 'Untitled',
    content: item && typeof item.content === 'string' ? item.content : '',
    ingestedAt: new Date().toISOString()
  }));

  store.items.push(...createdItems);
  writeStore(store);

  return res.status(201).json({ added: createdItems.length, items: createdItems });
});

app.get('/items', (_req, res) => {
  const store = readStore();
  return res.json({ count: store.items.length, items: store.items });
});

app.listen(PORT, () => {
  console.log(`Demo backend API running on http://localhost:${PORT}`);
});
