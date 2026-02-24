# Swarm MVP Demo

## Backend API Demo

A minimal Node.js + Express API is available in `api/server.js`.

### Endpoints

- `POST /sources` adds a source
- `GET /sources` lists sources
- `POST /ingest` ingests mock items for a source
- `GET /items` lists ingested items

### Data Storage

Data is persisted to `data/store.json`.

`data/seed.json` includes sample seed data and `data/store.json` is initialized with that sample.

### Run

```bash
npm install
npm start
```

The API runs on `http://localhost:3000` by default.

### Quick Examples

```bash
curl -X POST http://localhost:3000/sources \
  -H 'Content-Type: application/json' \
  -d '{"name":"News Feed","url":"https://example.com/news"}'

curl http://localhost:3000/sources

curl -X POST http://localhost:3000/ingest \
  -H 'Content-Type: application/json' \
  -d '{"sourceId":"src_demo_docs","items":[{"title":"Mock item","content":"hello"}]}'

curl http://localhost:3000/items
```
