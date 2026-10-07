# claude-orc

A cheap build pipeline. Claude Code plans and reviews; cheap workers write the code.

```
claude orc "make a flappy bird game"
```

1. **Plan** (Claude Sonnet, plan mode). Claude designs the build and writes task cards in `tasks/`. You approve the plan.
2. **Build** (no Claude). `run-plan` sends each card to a worker through `delegate`:
   - `hermes`: Hermes Agent on OpenRouter `z-ai/glm-5.3-flash`
   - `gemma`: Hermes Agent on a local Gemma 4 E4B (`llama-server`, free)

   Cards run in dependency waves, in parallel. A failed card is retried once on a stronger model. Each passing wave is committed.
3. **Check** (Claude). Claude runs the tests and writes `REPORT.md`.

Measured on a flappy-bird build: $0.147 in total, versus $0.426 for Claude Opus building it alone (API list prices).

## Files

| Path | Installed to | What it does |
|---|---|---|
| `bin/orc` | `~/.local/bin/orc` | Launcher: scaffolds `tasks/` and `PLAN.md`, starts Claude with the protocol |
| `bin/run-plan` | `~/.local/bin/run-plan` | Runs every card: waves, parallelism, retry, commits, `RUN_SUMMARY.md` |
| `bin/delegate` | `~/.local/bin/delegate` | Sends one card to a worker, runs its acceptance check, prints a short report |
| `bin/gemma-up` | `~/.local/bin/gemma-up` | Starts the local Gemma server if it is not running |
| `config/protocol.md` | `~/.config/orc/` | Claude's rules in the default mode |
| `config/protocol-phased.md` | `~/.config/orc/` | Rules for `claude orc --phased` (Claude checks each phase) |
| `config/empty-mcp.json` | `~/.config/orc/` | Loads no MCP servers in orc sessions |
| `hermes/providers.yaml` | appended to `~/.hermes/config.yaml` | The `localgemma` provider |
| `shell/zshrc-snippet.zsh` | appended to `~/.zshrc` | Makes `claude orc` call `orc` |

## Install

```
git clone <this repo> ~/claude-orc && ~/claude-orc/install.sh
```

The installer symlinks the files, so you edit them in this repo and commit. It also lists anything missing: Hermes Agent, `llama-server` (`brew install llama.cpp`), the Gemma model file, or the OpenRouter key in `~/.hermes/.env`.

## Settings

| Variable | Default | Effect |
|---|---|---|
| `ORC_MODEL` | `sonnet` (`opusplan` with `--phased`) | Claude model; use `opus` for big projects |
| `ORC_EFFORT` | `medium` | Claude effort level |
| `ORC_TOOLS` | `Bash,Read,Write,Edit,ExitPlanMode` | Claude's built-in tools |
| `HERMES_WORKER_MODEL` | `z-ai/glm-5.3-flash` | Model for the hermes tier |
| `DELEGATE_TIMEOUT` | `600` | Seconds before a worker run is killed |
| `RUNPLAN_TIMEOUT` | `2700` | Seconds before `run-plan` stops starting new waves |
| `DELEGATE_NO_FALLBACK` | off | `1` stops the hermes tier falling back to Gemma when OpenRouter has no credits |
| `DELEGATE_TOOLSETS` | `file,terminal` | Hermes toolsets per worker |
| `DELEGATE_YOLO` | off | `1` skips Hermes' approval prompts |

Logs and per-run usage (tokens, cost) are in `~/.cache/delegate/`.
