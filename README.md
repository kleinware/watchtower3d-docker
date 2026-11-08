# Watchtower (3D print farm manager) in Docker

Runs the [Watchtower](https://watchtower3d.com) Linux `.deb` in an Ubuntu 24.04
container, reachable only over your tailnet through a Tailscale Serve sidecar
(no host ports published, Funnel off).

> Not the Docker auto-updater of the same name.

## Compose files

| File | Use when | Access |
| --- | --- | --- |
| `docker-compose.yml` | You use Tailscale (default) | `https://<TS_HOSTNAME>.<tailnet>.ts.net`, no host ports |
| `docker-compose.standalone.yml` | You don't use Tailscale | `http://<host>:<WATCHTOWER_WEB_PORT>` |

Both read the same `.env`; each ignores the variables it doesn't use.

## Setup

1. Download the x86_64 `.deb` from watchtower3d.com into this folder
   (it is git-ignored).
2. `cp .env.example .env` and fill in every value (filename, PUID/PGID, paths,
   timezone, plus `TS_HOSTNAME`/`TS_AUTHKEY` or `WATCHTOWER_WEB_PORT`).
3. Make sure the appdata folders exist and are owned by `PUID:PGID`.
4. Start one of the stacks:

        # Tailscale sidecar
        docker compose up -d --build

        # No Tailscale (publishes WATCHTOWER_WEB_PORT)
        docker compose -f docker-compose.standalone.yml up -d --build

With Tailscale, set `TS_AUTHKEY` for first login: without it the sidecar's login
step times out after 60s (or do a one-time `tailscale up` against the state
folder). Printers must be added by IP (no mDNS/SSDP discovery from a bridge
network). For standalone, only expose the port on a trusted network or behind
your own proxy/VPN.

## License

The files here are MIT-licensed (see `LICENSE`). The Watchtower software itself
is not covered; check its own terms before redistributing the `.deb`.
