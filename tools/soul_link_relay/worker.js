// Infinite Fusion Nuzlocke -- Soul Link relay
//
// A tiny Cloudflare Worker + KV store. Each player in a room owns exactly one
// JSON blob (their ledger); anyone with the room code can read every blob.
// There are no accounts: the room code is the only secret, and the data is a
// list of Pokemon names and areas, so the threat model is "don't be annoying".
//
// Routes
//   POST /room                         -> { "code": "ABC234" }   create a room
//   GET  /room/:code                   -> { "players": { key: ledger, ... } }
//   POST /room/:code/:player           <- ledger JSON (<= 16 KB)   upsert
//   POST /room/:code/:player/leave     -> 204                       delete
//   GET  /health                       -> "ok"
//
// KV layout: room:<code>:_meta  and  room:<code>:<player>. Entries expire after
// ROOM_TTL_DAYS of inactivity (each write refreshes the TTL).

const ROOM_TTL_DAYS = 60;
const MAX_BODY_BYTES = 16 * 1024;
const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O/1/I
const CODE_RE = /^[A-Z2-9]{6}$/;
const PLAYER_RE = /^[A-Za-z0-9_-]{1,40}$/;

const json = (obj, status = 200) =>
  new Response(JSON.stringify(obj), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" },
  });
const text = (body, status = 200) => new Response(body, { status, headers: { "cache-control": "no-store" } });

function randomCode() {
  const bytes = new Uint8Array(6);
  crypto.getRandomValues(bytes);
  let out = "";
  for (const b of bytes) out += CODE_ALPHABET[b % CODE_ALPHABET.length];
  return out;
}

async function roomExists(env, code) {
  return (await env.SOUL_LINK.get(`room:${code}:_meta`)) !== null;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const parts = url.pathname.split("/").filter(Boolean);
    const ttl = { expirationTtl: ROOM_TTL_DAYS * 86400 };

    if (parts.length === 1 && parts[0] === "health") return text("ok");
    if (parts[0] !== "room") return text("not found", 404);

    // POST /room -> create
    if (parts.length === 1) {
      if (request.method !== "POST") return text("method not allowed", 405);
      for (let attempt = 0; attempt < 5; attempt++) {
        const code = randomCode();
        if (await roomExists(env, code)) continue;
        await env.SOUL_LINK.put(`room:${code}:_meta`, JSON.stringify({ created: Date.now() }), ttl);
        return json({ code });
      }
      return text("could not allocate a room code", 503);
    }

    const code = parts[1];
    if (!CODE_RE.test(code)) return text("bad room code", 400);

    // GET /room/:code -> everyone's ledger
    if (parts.length === 2) {
      if (request.method !== "GET") return text("method not allowed", 405);
      if (!(await roomExists(env, code))) return text("room not found", 404);
      const list = await env.SOUL_LINK.list({ prefix: `room:${code}:` });
      const players = {};
      for (const k of list.keys) {
        const player = k.name.slice(`room:${code}:`.length);
        if (player === "_meta") continue;
        const raw = await env.SOUL_LINK.get(k.name);
        if (!raw) continue;
        try { players[player] = JSON.parse(raw); } catch (_) { /* skip corrupt */ }
      }
      return json({ players });
    }

    const player = parts[2];
    if (!PLAYER_RE.test(player) || player === "_meta") return text("bad player key", 400);
    if (request.method !== "POST") return text("method not allowed", 405);
    if (!(await roomExists(env, code))) return text("room not found", 404);

    // POST /room/:code/:player/leave
    if (parts.length === 4 && parts[3] === "leave") {
      await env.SOUL_LINK.delete(`room:${code}:${player}`);
      return text("", 204);
    }

    // POST /room/:code/:player -> upsert ledger
    if (parts.length === 3) {
      const body = await request.text();
      if (body.length > MAX_BODY_BYTES) return text("ledger too large", 413);
      let parsed;
      try { parsed = JSON.parse(body); } catch (_) { return text("body must be JSON", 400); }
      if (!parsed || typeof parsed !== "object" || typeof parsed.areas !== "object") return text("not a ledger", 400);
      parsed.key = player;
      parsed.received = Date.now();
      await env.SOUL_LINK.put(`room:${code}:${player}`, JSON.stringify(parsed), ttl);
      // Keep the room alive as long as anyone writes to it.
      await env.SOUL_LINK.put(`room:${code}:_meta`, JSON.stringify({ touched: Date.now() }), ttl);
      return text("", 204);
    }

    return text("not found", 404);
  },
};
