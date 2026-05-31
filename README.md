# cli-music-player
A lightweight Bash script to stream YouTube music directly in the terminal using mpv and yt-dlp.

## Aternos server control script

This repository also includes `./aternos.sh` to manage an Aternos server:

- `status` → show current status
- `on` → start server
- `off` → stop server

### Requirements

- `curl`
- `jq`

### Environment variables

- `ATERNOS_SESSION`
- `ATERNOS_SERVER`
- `ATERNOS_SEC`
- `ATERNOS_BASE_URL` (optional, defaults to `https://aternos.org`)

### Usage

```bash
chmod +x ./aternos.sh
ATERNOS_SESSION="..." \
ATERNOS_SERVER="..." \
ATERNOS_SEC="..." \
./aternos.sh status
```
