# `claude orc [goal]` -> orchestration pipeline (see ~/.local/bin/orc); everything else -> normal claude
claude() {
  if [[ "${1:-}" == orc ]]; then shift; orc "$@"; else command claude "$@"; fi
}
