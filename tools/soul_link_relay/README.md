# Soul Link relay (Cloudflare Worker)

The in-game Soul Link talks to this relay. Players never log in to anything:
one player creates a room code in-game, the other types it in.

## Deploy (one time, ~2 minutes)

```
cd tools/soul_link_relay
npx wrangler login                       # opens the browser once
npx wrangler kv namespace create SOUL_LINK
#   -> paste the printed id into wrangler.toml
npx wrangler deploy
#   -> prints https://if-soul-link.<your-subdomain>.workers.dev
```

Free-tier limits (100k requests/day, 1k KV writes/day) are far above what a
handful of players generate: the game pushes only when something changed and
pulls at most every 30 seconds while you change maps.

## Point the game at it

Either edit `DEFAULT_RELAY_URL` at the top of
`Data/Scripts/052_InfiniteFusion/Gameplay/NuzlockeSoulLink.rb` before shipping
a build, or drop a `soul_link_relay.txt` file containing the URL next to
`InfiniteFusion.exe` (handy for testing without editing scripts).

## Smoke test

```
curl -X POST https://<worker>/room                      # {"code":"ABC234"}
curl -X POST https://<worker>/room/ABC234/Matt_123 \
     -d '{"v":1,"name":"Matt","areas":{"Route 3":{"species":"PIDGEY","name":"Bird","status":"alive","location":"party"}}}'
curl https://<worker>/room/ABC234                       # {"players":{"Matt_123":{...}}}
curl -X POST https://<worker>/room/ABC234/Matt_123/leave
```

## Data & retention

One JSON blob per player per room, at most 16 KB, containing trainer name,
Pokémon names/species per area and alive/dead/failed status. Rooms expire 60
days after the last write. Anyone who knows a room code can read that room's
blobs; codes are 6 characters from a 32-symbol alphabet (about 1 billion).
