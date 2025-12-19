#!/usr/bin/env bash
set -euo pipefail

# Ensure Rust (cargo)
if ! command -v cargo >/dev/null 2>&1; then
  curl -fsSL https://sh.rustup.rs | sh -s -- -y
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
fi

# Build & install from the current (cloned) repo
cargo install --locked --path .

# Ensure ~/.cargo/bin is on PATH for future shells
if ! grep -q '\.cargo/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Add Bash wrapper to cd into the first printed path (idempotent)
WRAPPER='
rcdn() {
    dir=$(command rcd "$@" | head -n1)
    if [ -d "$dir" ]; then
        builtin cd -- "$dir" || return
        # Open main file if exists
        for f in main.*; do
            [ -f "$f" ] && nvim "$f" && break
        done
    fi
}
'
if ! grep -Fqx "$WRAPPER" "$HOME/.bashrc" 2>/dev/null; then
  { echo; echo '# rcd shell wrapper'; echo "$WRAPPER"; } >> "$HOME/.bashrc"
fi

# Make rcd usable now in this shell, too
export PATH="$HOME/.cargo/bin:$PATH"

echo "Installed. To enable wrapper in your current shell: source ~/.bashrc"
