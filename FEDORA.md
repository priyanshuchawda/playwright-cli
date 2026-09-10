# Fedora fork workflow

This fork adds **Fedora Linux** support on top of [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli). Browser engines and `install-deps` live in [priyanshuchawda/playwright](https://github.com/priyanshuchawda/playwright) (`feat/fedora-linux-support`).

## Layout on this machine

| Path | Remote | Role |
|------|--------|------|
| `~/playwright-cli` | `origin` → your fork, `upstream` → Microsoft | CLI + skills + CI |
| `~/playwright` | `fork` → your fork, `upstream` → Microsoft | Fedora `dnf` deps, host platform |

## First install (Fedora)

```bash
git clone https://github.com/priyanshuchawda/playwright-cli.git ~/playwright-cli
git clone https://github.com/priyanshuchawda/playwright.git ~/playwright
cd ~/playwright && git checkout feat/fedora-linux-support
~/playwright-cli/scripts/setup-fedora.sh
```

Global `playwright-cli` will use **local built** `playwright-core` from `~/playwright` (Fedora-aware).

### Cheap / low-resource tips

- **GitHub Actions CI is off** for this fork (no minutes on push). Test with `npm run test` and `setup-fedora.sh` locally.
- **Skip heavy reinstalls** — setup skips `playwright` `npm ci` if `node_modules` exists; force only with `PW_FORCE_NPM_CI=1`.
- **Rebuild only** — after pulling code: `cd ~/playwright && node utils/build/build.js --disable-install` then re-run `setup-fedora.sh`.
- **Optional RPMs** — dry-run may list fonts/Xvfb; install only if you need PDF/screenshots with specific fonts or headed/Xvfb workflows.
- **RAM/battery** — default headless; run `playwright-cli close-all` when done.

## Sync when Microsoft updates

```bash
~/playwright-cli/scripts/sync-upstream.sh
```

That script:

1. Fetches `upstream/main` for both repos  
2. Merges Microsoft `main` into your Playwright Fedora branch and into your current `playwright-cli` branch  
3. Rebuilds Playwright and reinstalls the CLI  

If a merge conflicts, fix files (usually `nativeDeps.ts`, `hostPlatform.ts`, `dependencies.ts`, `registry/index.ts`), commit in `~/playwright`, then run `~/playwright-cli/scripts/setup-fedora.sh`.

## Day-to-day commands

```bash
playwright-cli install-browser chromium --with-deps --dry-run
playwright-cli open https://example.com
playwright-cli install --skills
```

## Push your changes

```bash
cd ~/playwright && git push fork feat/fedora-linux-support
cd ~/playwright-cli && git push origin main
```
