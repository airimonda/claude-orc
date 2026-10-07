#!/usr/bin/env bash
# Install claude-orc: symlink the scripts and config from this repo into place, so the repo
# stays the single source of truth (edit here, commit, done).
#   ./install.sh
# Safe to re-run. Existing non-symlink files are moved to <name>.bak-<timestamp> first.
set -euo pipefail
repo="$(cd "$(dirname "$0")" && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"

link() {  # link <repo file> <target path>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then mv "$dst" "$dst.bak-$stamp"; echo "backup: $dst.bak-$stamp"; fi
  ln -sfn "$src" "$dst"
  echo "linked: $dst -> $src"
}

for f in orc delegate run-plan gemma-up; do link "$repo/bin/$f" "$HOME/.local/bin/$f"; done
for f in protocol.md protocol-phased.md empty-mcp.json; do link "$repo/config/$f" "$HOME/.config/orc/$f"; done

# zsh wrapper for `claude orc`
if ! grep -q 'orc "\$@"; else command claude' "$HOME/.zshrc" 2>/dev/null; then
  { echo; cat "$repo/shell/zshrc-snippet.zsh"; } >> "$HOME/.zshrc"
  echo "added: claude() wrapper to ~/.zshrc (open a new terminal)"
fi

# Hermes provider for local Gemma
if [[ -f "$HOME/.hermes/config.yaml" ]] && ! grep -q 'localgemma:' "$HOME/.hermes/config.yaml"; then
  { echo; cat "$repo/hermes/providers.yaml"; } >> "$HOME/.hermes/config.yaml"
  echo "added: localgemma provider to ~/.hermes/config.yaml"
fi

# Checks for things this script does not install
command -v hermes >/dev/null      || echo "missing: hermes (Hermes Agent CLI)"
command -v llama-server >/dev/null || echo "missing: llama-server (brew install llama.cpp)"
[[ -f "$HOME/models/gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf" ]] \
  || echo "missing: Gemma model -> curl -L -o ~/models/gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf https://huggingface.co/unsloth/gemma-4-E4B-it-qat-GGUF/resolve/main/gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf"
grep -q '^OPENROUTER_API_KEY=' "$HOME/.hermes/.env" 2>/dev/null || echo "missing: OPENROUTER_API_KEY in ~/.hermes/.env"
echo "done"
