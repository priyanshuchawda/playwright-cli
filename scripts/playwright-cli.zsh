# Playwright CLI on Fedora (fork-linked). Sourced from ~/.zshrc.

if ! command -v playwright-cli >/dev/null 2>&1; then
  return 0
fi

# Quieter non-interactive / agent runs
export NO_UPDATE_NOTIFIER="${NO_UPDATE_NOTIFIER:-1}"

# Optional default session for agents (override per project)
# export PLAYWRIGHT_CLI_SESSION="${PLAYWRIGHT_CLI_SESSION:-default}"

pw() {
  command playwright-cli "$@"
}

pw-check() {
  command playwright-cli install-browser chromium --with-deps --dry-run
}

pw-relink() {
  "${PLAYWRIGHT_CLI_ROOT:-$HOME/playwright-cli}/scripts/setup-fedora.sh"
}

alias pwo='playwright-cli open'
alias pwc='playwright-cli close'
alias pws='playwright-cli snapshot'
alias pwl='playwright-cli list'
