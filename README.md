# Remote Control Router

Lets Claude check, diagnose, and (with your approval) fix your home router remotely.

## How it works

```
Claude (cloud) ──Remote Control──▶ always-on home computer ──LAN──▶ router
```

- The router's admin interface is **never exposed to the internet**.
- A computer at home runs Claude with Remote Control and shares this folder.
- Router credentials live only in `.env` on that computer (git-ignored).

## Setup (one time, on the home computer)

1. Clone this repo onto a computer that stays on and is on the home network.
2. `cp .env.example .env` and fill in the router IP, username, and password.
3. Make this folder available through Remote Control
   (Claude desktop app → Settings → Claude Code → Remote Control, or run
   `claude remote-control` in this folder).
4. Test it: `./scripts/diagnose.sh`

## Ground rules for Claude

- Read-only checks (`scripts/diagnose.sh`, viewing router status) can run any time.
- **Any change to the router is discussed and approved first**, with a config
  backup taken beforehand.
- Never enable WAN/remote admin or open ports without explicit approval.
