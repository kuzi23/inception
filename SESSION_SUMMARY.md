# Inception — Session Summary (2026-08-13)

Login: **mkwizera** · Domain: **mkwizera.42.fr** · Remote: `https://github.com/alexnik42/inception.git` (⚠️ verify this is your correct account before pushing)

## ⚠️ MOST IMPORTANT: NOTHING IS PUSHED YET

As of the end of this session, **all changes below are only local uncommitted edits**. Nothing has been committed or pushed to git. If the VM is deleted before running the commands in "Next Steps" below, all of today's work is lost.

## Next Steps (do this FIRST tomorrow, before anything else)

```sh
cd ~/Desktop/inception
git status                # sanity check — should show all the modified/untracked files listed below
git add -A
git commit -m "Fix compose compatibility, pin base images, secrets handling, docs, and startup scripts"
git push origin main
```

Then verify nothing sensitive leaked:
```sh
git ls-files | grep -i secret     # should show nothing (secrets/ folder must not be tracked)
git show HEAD:srcs/.env           # should show only placeholder-safe values
```

## What Was Wrong At The Start

1. `make` failed: `docker-compose: No such file or directory` — system only had `docker compose` (v2), not the legacy `docker-compose` binary.
2. Full compliance audit against the 42 Inception subject revealed many gaps (see "Fixes Applied" below).
3. Website was completely unreachable — root caused through several stacked issues (see "Root Causes Found & Fixed").
4. `mkwizera` user was not in the `docker` group → all docker commands failed with permission denied.

## Fixes Applied

### Makefile
- Auto-detects `docker compose` vs `docker-compose` (`COMPOSE` variable), fails clearly if neither exists.

### docker-compose.yml
- Base images pinned: `debian:11.9-slim` (fixed point release, Debian 11 = penultimate stable vs Debian 12 bookworm).
- Own images explicitly tagged `:v1` (avoids implicit `latest`).
- Named volumes `wp`/`db` use `driver_opts` (`type: none, o: bind, device: /home/mkwizera/data/{wordpress,mariadb}`) — satisfies both "must be named volumes, not bind mounts" AND "must store data in /home/login/data" subject rules simultaneously.
- Added `secrets:` top-level block referencing `../secrets/db_password.txt` and `../secrets/db_root_password.txt`.
- `mariadb`/`wordpress` services use `MYSQL_PASSWORD_FILE` / `MYSQL_ROOT_PASSWORD_FILE` env vars pointing to `/run/secrets/*`.

### MariaDB (`srcs/requirements/mariadb/`)
- Dockerfile: `debian:11.9-slim`, installs `mariadb-server`, runs custom `mariadb_start.sh` as ENTRYPOINT.
- New `tools/mariadb_start.sh`: reads secrets from `_FILE` env vars, runs `mariadb-install-db` if needed, starts mysqld temporarily via socket to create DB/user/grants idempotently (marker file `.inception_init`), shuts down, then `exec`s the real foreground `mysqld` (PID 1, no backgrounding of the final process).
- `initial_db.sql` sanitized (no longer contains hardcoded credentials — kept as a reference-only file, actual init now happens in the script).

### WordPress (`srcs/requirements/wordpress/`)
- Dockerfile: `debian:11.9-slim`, `php-fpm` (7.4) + `php-mysqli` + `wp-cli` via curl (no ready-made WP image).
- `www.conf`: **`clear_env = no`** added — critical fix, see gotchas below.
- `wordpress_start.sh`: waits for DB reachability before installing, uses its own completion marker (`.inception_init`) instead of just checking `wp-config.php` existence (avoids false-positive "already configured" after a crashed partial install).
- `wp-config.php`: DB credentials now read via `getenv('MYSQL_*')` instead of hardcoded values.

### NGINX (`srcs/requirements/nginx/`)
- Dockerfile: `debian:11.9-slim`, fixed broken entrypoint path (`var/www/...` → `/var/www/...`).
- `conf/default`: `server_name` and cert `CN` updated from a leftover `crendeha.42.fr` to `mkwizera.42.fr`.
- TLS restricted to `TLSv1.3` (subject allows 1.2 or 1.3).

### Docs
- `README.md` rewritten: correct italicized first line, Description/Instructions/Resources (with nested AI Usage subsection)/Technical Choices (VM vs Docker, Secrets vs Env, Network vs Host, Volumes vs Bind Mounts).
- `USER_DOC.md` and `DEV_DOC.md` created per Chapter VII requirements.
- `.gitignore` created — ignores the entire `secrets/` folder (per your explicit choice not to push it at all) and `srcs/.env.local`.
- `secrets/README.md` — local instructions for creating secret files (not pushed, since whole `secrets/` folder is gitignored).

## Root Causes Found & Fixed (the "site unreachable" saga)

1. **Docker group permission denied** — `mkwizera` wasn't in the `docker` group. Fixed via `sudo usermod -aG docker $USER` + `newgrp docker` (note: correct command is `newgrp`, not `newgroup`).
2. **Stale incompatible volume data** — `/home/mkwizera/data/mariadb` contained data from a *newer* MariaDB version (10.11.x, from earlier ad-hoc testing with an official Docker Hub image) that our Debian 11 MariaDB (10.5.29) couldn't read (`Unsupported redo log format`). Fixed by wiping volume contents via a throwaway container run (not host `rm`, since host user lacks permission on container-written files).
3. **`MYSQL_HOST` env leaking into MariaDB's own container** — since `.env` is shared via `env_file` across all services, MariaDB's own entrypoint script inherited `MYSQL_HOST=mariadb`, which made the `mysql`/`mysqladmin` CLI silently switch from `--protocol=socket` to TCP (mysql client behavior: non-`localhost` `MYSQL_HOST` forces TCP even with `--protocol=socket`), breaking local init. Fixed with `unset MYSQL_HOST` + explicit `-h localhost` in `mariadb_start.sh`.
4. **PHP-FPM `clear_env = yes` (default)** — stripped all container env vars from pool workers, so `wp-config.php`'s `getenv('MYSQL_*')` returned empty for real HTTP requests (but `wp-cli`, invoked directly from the shell, still worked fine since it inherits the shell's env directly) → "Database Error" page only via nginx, not via CLI install. Fixed with `clear_env = no` in `www.conf`.

## Current Verified State (as of last test)

- `docker compose ps`: all 3 containers (`mariadb`, `wordpress`, `nginx`) `Up`.
- `https://mkwizera.42.fr/` → HTTP 200, title "Inception WordPress" (not install wizard).
- `http://mkwizera.42.fr/` (port 80) → connection refused.
- TLS handshake confirmed on TLSv1.3.
- `docker volume inspect wp` / `db` → both show `Options.device` = `/home/mkwizera/data/{wordpress,mariadb}`.
- Comment persistence tested across a real VM reboot — confirmed working.

## Still TODO / Known Gaps

1. **Push everything to git** (see "Next Steps" above) — not done yet.
2. `srcs/.env` still has placeholder passwords:
   ```
   WP_ADMIN_PASSWORD=change_me_admin_password
   WP_USER_PASSWORD=change_me_user_password
   ```
   Fine for git-safety (not real leaked creds), but should be replaced with real values before the actual defense, then `make clean && make` to re-apply (WordPress bakes the password in at install time, not on every boot).
3. Bonus part **not implemented at all** (Redis, FTP, static site, Adminer, or free-choice service) — only relevant if mandatory part is graded perfect first.
4. Be ready to verbally explain (defense requirement, no code needed): Docker vs docker-compose, image-with-compose vs without, Docker vs VM benefits, directory structure rationale, docker-network explanation, how to log into the DB.
5. Be ready to do live during defense: log in as `mkwizerauser` and add a comment; log in as admin (`siteowner`) and edit a page, verify it reflects on the site; change a service's port in `docker-compose.yml` and rebuild/restart successfully.
6. `secrets/db_password.txt` / `secrets/db_root_password.txt` currently contain placeholder values (`change_me_db_password` / `change_me_root_password`) — fine functionally since nothing reads them except this stack, but recreate with real values if you regenerate the environment from scratch (see `secrets/README.md`).
7. There is a duplicate folder `~/Desktop/inception2` — confirmed to be an older, slightly stale backup (missing only trivial final doc/gitignore polish, otherwise identical `srcs/` content). Not needed once git push is done; safe to ignore/delete.

## Key File Reference

- `Makefile` — root, compose command auto-detection.
- `srcs/docker-compose.yml` — services, network, volumes, secrets.
- `srcs/.env` — non-secret runtime config (domain, DB name/user, WP titles/logins).
- `srcs/requirements/{mariadb,nginx,wordpress}/Dockerfile` — one per service, custom-built.
- `srcs/requirements/*/tools/*_start.sh` — custom entrypoint scripts.
- `secrets/db_password.txt`, `secrets/db_root_password.txt` — local-only, gitignored.
- `README.md`, `USER_DOC.md`, `DEV_DOC.md` — required documentation.
