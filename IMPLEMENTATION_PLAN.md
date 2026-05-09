# omp-zsh Implementation Plan

## Context

This document describes the implementation plan for a zsh plugin that enables interaction with the OMP (oh-my-pi) CLI tool via `:`-prefixed commands, modeled after the [forgecode zsh plugin](https://github.com/tailcallhq/forgecode/tree/main/shell-plugin).

### Reference Materials

| Document | Purpose |
|----------|---------|
| `PRODUCT_RULES.md` | Product requirements (source of truth) |
| `README.md` | Existing fish shell plugin for reference |
| [forgecode/shell-plugin](https://github.com/tailcallhq/forgecode/tree/main/shell-plugin) | Blueprint zsh plugin |
| [oh-my-pi](https://github.com/can1357/oh-my-pi) | OMP CLI tool (upstream) |

### OMP CLI Interface (Verified)

```
omp [options] [@files...] [messages...]
omp -p "prompt"            # With --no-session: stateless prompt, emit answer and exit
omp -c "prompt"           # Continue most recent session
omp --no-session          # Stateless mode (do not persist session)
omp commit                # AI-powered git commit
omp commit --dry-run      # Preview commit message
omp stats                 # Show usage statistics
```

### Command Reference

| `: ` command | OMP invocation | Notes |
|---|---|---|
| `: <prompt>` *(default)* | `omp -c "<prompt>"` | Continue most recent session |
| `: <prompt>` *(after `:new`)* | `omp "<prompt>"` | Start new session |
| `:c <prompt>` | `omp -c "<context>\n<prompt>"` | Continue with context prepended |
| `:s <prompt>` | `omp --no-session -p "<prompt>"` | Stateless; plain stdout answer goes to buffer |
| `:new` | clears session state | No OMP call; next `: ` triggers `omp "<prompt>"` |
| `:new <prompt>` | `omp "<prompt>"` | Start new session and process prompt |
| `:commit` | `omp commit` | Direct subcommand |
| `:commit --dry-run` | `omp commit --dry-run` | Output goes to buffer |
| `:stats` | `omp stats` | Direct subcommand |
| `:help` | `omp --help` | Built-in help |

## Architecture

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Shell compatibility | **zsh only** | Aligns with forgecode blueprint; fish has separate implementation |
| Command interception | **ZLE widget** | Native zsh mechanism; fish uses native functions instead |
| State management | **Session flag only** | Plugin tracks whether we're in a fresh session; OMP manages session continuity internally via `-c` |
| CLI invocation | **`omp` on PATH** | Configurable via `OMP_BIN` environment variable |
| Multiline handling | **Terminal handles input** | Shift+Enter inserts newlines; plugin passes buffer as-is to OMP |
| Session persistence | **OMP CLI manages sessions** | `-c` continues; bare `omp` starts new; no plugin-side session ID tracking |
| Installation | **Manual copy-paste** | No `omp zsh setup`; user copies files to `.zshrc` load path |

### Key Difference from Forgecode

Forgecode ships a Rust binary (`forge`) that the zsh plugin invokes via `forge zsh plugin` / `forge zsh theme`. The **OMP CLI is external** (`omp`), so the plugin is purely a shell integration layer that:

1. Intercepts `:` commands via ZLE widget
2. Formats and passes them to `omp`
3. Handles buffer manipulation for `:s` (suggest) and `:commit --dry-run`
4. Tracks only whether the current session is fresh (for `:new`)

## File Structure

```
omp-zsh/
├── omp.plugin.zsh           # Main plugin entry point (sources all modules)
├── lib/
│   ├── config.zsh            # Configuration variables and defaults
│   ├── dispatcher.zsh        # Main ZLE widget and command routing
│   ├── helpers.zsh           # Utility functions (_omp_exec, logging)
│   ├── context.zsh           # Terminal context capture (preexec/precmd hooks)
│   ├── bindings.zsh          # Key bindings and widget registration
│   ├── completion.zsh        # TAB completion for commands and arguments
│   └── actions/
│       ├── core.zsh           # :new, :help
│       ├── session.zsh        # :c (continue with context)
│       ├── suggest.zsh        # :s (command suggestion to buffer)
│       ├── commit.zsh         # :commit, :commit --dry-run
│       └── stats.zsh          # :stats
├── completions/
│   └── _omp                  # Zsh completion function
└── README.md                 # Installation and usage documentation
```

## Implementation Phases

### Phase 1: Foundation

**Goal**: Core interception mechanism working with basic `: <prompt>` command.

| Task | File | Description |
|------|------|-------------|
| Plugin scaffold | `omp.plugin.zsh` | Source all modules in correct order |
| Config defaults | `lib/config.zsh` | Define `OMP_BIN`, session flag, state variables |
| Dispatcher widget | `lib/dispatcher.zsh` | `omp-accept-line` widget that intercepts `:` lines |
| Key bindings | `lib/bindings.zsh` | Register widget, bind Enter to it |
| Basic helpers | `lib/helpers.zsh` | `_omp_exec()`, logging utilities |

**Acceptance**: Typing `: hello world` and pressing Enter invokes `omp -c "hello world"` and displays output.

### Phase 2: Session Management

**Goal**: `:new` clears session flag so next `: ` starts a fresh session. `:new <prompt>` immediately starts a new session with the given prompt.

| Task | File | Description |
|------|------|-------------|
| Session flag | `lib/config.zsh` | `_OMP_FRESH_SESSION` flag (true after `:new`, false after first `: `) |
| New session action | `lib/actions/core.zsh` | `:new` clears flag; `:new <prompt>` calls `omp "<prompt>"` |
| Session routing | `lib/dispatcher.zsh` | `: <prompt>` → `omp "<prompt>"` if fresh, else `omp -c "<prompt>"` |
| Help action | `lib/actions/core.zsh` | `:help` runs `omp --help` |

**Acceptance**: `:new` then `: explain X` starts a new session; `: explain X` then `: add Y` continues the same session.

### Phase 3: Command Context (`:c`)

**Goal**: `:c <prompt>` prepends last command + exit code to prompt.

| Task | File | Description |
|------|------|-------------|
| Context capture | `lib/context.zsh` | Track last command and exit code via precmd hook |
| Continue action | `lib/actions/session.zsh` | `:c <prompt>` formats context and calls `omp -c "<context>\n<prompt>"` |

**Context format** (v1 — command + exit code only):
```
Last command: <cmd>
Exit code: <code>

<prompt>
```

Stdout/stderr capture is deferred to a future iteration.

**Acceptance**: After running `ls -la` (exit 0), `:c why did this work` sends context with the command info.

### Phase 4: Command Suggestion (`:s`)

**Goal**: `:s <prompt>` generates a shell command and puts it in the buffer for review.

| Task | File | Description |
|------|------|-------------|
| Suggest action | `lib/actions/suggest.zsh` | Call `omp --no-session -p "<prompt>"`, capture plain stdout |
| Buffer manipulation | `lib/helpers.zsh` | Place stdout in `BUFFER` |

**Implementation**: `omp --no-session -p "<prompt>"` — `--no-session` prevents persistence, `-p` emits the answer and exits. The stdout response (plain text) is placed directly in the zsh buffer. User presses Enter to execute or edits first.

**Acceptance**: `:s find large log files` places a command like `find . -name "*.log" -size +100M` in the buffer.

### Phase 5: Git Integration (`:commit`)

**Goal**: AI-assisted git commit with optional dry-run.

| Task | File | Description |
|------|------|-------------|
| Commit action | `lib/actions/commit.zsh` | `:commit` → `omp commit`; `:commit --dry-run` previews |
| Buffer handling | `lib/helpers.zsh` | For dry-run, place `git commit -m "..."` in buffer for review |

**Acceptance**: `:commit` commits directly; `:commit --dry-run` shows `git commit -m "..."` in buffer for the user to edit before committing.

### Phase 6: Statistics (`:stats`)

**Goal**: Display OMP usage statistics.

| Task | File | Description |
|------|------|-------------|
| Stats action | `lib/actions/stats.zsh` | Invoke `omp stats` and display output |

**Acceptance**: `:stats` displays OMP usage information.

### Phase 7: Multiline Prompts

**Goal**: Users type multiline prompts via Shift+Enter; all lines sent as one prompt.

This is explicitly marked as a **Critical Requirement** in PRODUCT_RULES.md.

**Implementation**: Shift+Enter inserts newlines directly into the zsh buffer — the terminal handles the input, not the plugin. The plugin receives the complete buffer with newlines intact and passes it to OMP as a single quoted string argument. No state machine, no continuation detection.

**Task**: Verify multiline string is properly quoted when passed to OMP.

**Example**: User types `: line 1<Shift+Enter>line 2<Shift+Enter>line 3` then presses Enter. The plugin calls `omp -c "line 1\nline 2\nline 3"` (or `omp "..."` if fresh) and displays the response.

**Acceptance**: The three-line example from PRODUCT_RULES.md sends all three lines as one prompt.

### Phase 8: Completion

**Goal**: TAB completion for commands and arguments.

| Task | File | Description |
|------|------|-------------|
| Completion widget | `lib/completion.zsh` | ZLE completion widget for `:`, `:c`, `:s`, `:commit` |
| Zsh completion | `completions/_omp` | `_arguments` style completion function |

**Acceptance**: Typing `:c <TAB>` offers completions (e.g., recent commands, files).

### Phase 9: Documentation

**Goal**: Installation and usage docs matching the fish plugin's structure.

| Task | File | Description |
|------|------|-------------|
| README | `README.md` | Installation instructions, usage examples, file structure |
| License | `LICENSE` | MIT (matching fish plugin) |

## Configuration Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `OMP_BIN` | `omp` | Path to OMP CLI binary |
| `_OMP_FRESH_SESSION` | `false` | True after `:new`, false after first `: ` prompt |

Plugin state (not user-configurable):

| Variable | Purpose |
|----------|---------|
| `_OMP_LAST_CMD` | Last executed command (for `:c`) |
| `_OMP_LAST_EXIT` | Last exit code (for `:c`) |

## Verification Plan

| Phase | Test |
|-------|------|
| 1 | `: hello` invokes `omp -c "hello"` and displays response |
| 2 | `:new` then `: ` calls `omp "<prompt>"` (fresh); `: ` then `: ` calls `omp -c "<prompt>"` (continue) |
| 3 | After `ls`, `:c explain` includes `ls` and exit code in context |
| 4 | `:s find large files` places command in buffer |
| 5 | `:commit` commits; `:commit --dry-run` shows `git commit -m "..."` in buffer |
| 6 | `:stats` displays statistics |
| 7 | Shift+Enter multiline sends all lines as one prompt |
| 8 | TAB completion works for all commands |
| 9 | README accurately reflects implementation |
