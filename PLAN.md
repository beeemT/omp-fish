# omp-fish: Migration Plan from Forge Code

**Status**: Draft for discussion
**Last Updated**: 2026-05-08

## Overview

This document outlines the plan to create fish shell helpers that wrap the `omp` CLI (oh-my-pi), enabling a `: <prompt>` workflow similar to Forge Code but powered by omp.

---

## Key Simplifications (User Input)

1. **No session ID capture needed** - Use `omp --continue` always, which correctly handles multiple fish processes on the same workspace. This eliminates race conditions.

2. **`:s` auto-context** - Automatically inject context into stateless prompts: current directory and shell type (NO git info).

3. **Multiline input capture** - Capture the entire command line input including multiline content (fish supports multiline editing). Pass the full input as a single string prompt to omp.

---

## Verified CLI Behavior

| Command | Behavior |
|---------|----------|
| `omp -p "prompt"` | Non-interactive, creates session, returns answer |
| `omp --continue -p "prompt"` | Continue last session in cwd (works cross-process!) |
| `omp --no-session -p "prompt"` | Ephemeral, no session saved |
| `omp commit [--dry-run]` | AI-assisted git commit |

**Session storage**: `~/.omp/agent/sessions/<cwd-key>/<timestamp>_<id>.jsonl`

---

## Command Mapping

| Forge Command | omp Equivalent | Notes |
|--------------|----------------|-------|
| `:` (space after) | `omp --continue -p "<prompt>"` | Continue session |
| `:s <prompt>` | `omp --no-session -p "<prompt>\n\nContext:\n<auto-context>"` | Stateless shell commands |
| `:new` | `omp --continue -p "clear context and start fresh"` | Reset session context |
| `:commit` | `omp commit [--dry-run]` | AI-assisted commit |
| `:stats` | `omp stats` | Usage statistics |

**Multiline handling**: The entire input is captured (including newlines from fish multiline editing) and passed as a single prompt string to omp.

---

## File Structure

```
omp-fish/
├── conf.d/
│   └── omp.fish                    # Auto-loader
├── functions/
│   ├── __omp_helpers.fish          # Shared utilities
│   ├── __omp_exec.fish             # Core CLI wrapper
│   └── __omp_dispatch.fish         # Command parser
├── completions/
│   └── omp.fish                    # TAB completion
└── README.md
```

**No session state file needed!** - `--continue` handles everything.
---

## State Variables

None required - `--continue` handles everything.

## Function Inventory

| Function | Purpose |
|----------|---------|
| `__omp_helpers.fish` | Colors, escape, log, detect-shell, build-context |
| `__omp_exec.fish` | `__omp_exec_session` (with model type) and `__omp_exec_stateless` |
| `__omp_dispatch.fish` | Parse `:command` input, route to action |

---

## Implementation Phases

### Phase 1: Core Infrastructure

**Goal**: Basic scaffolding and helpers.

#### 1.1 `__omp_helpers.fish`

```fish
# Color constants
set -g __omp_color_info    (tput setaf 4)   # Blue
set -g __omp_color_success (tput setaf 2)   # Green
set -g __omp_color_warn     (tput setaf 3)   # Yellow
set -g __omp_color_error    (tput setaf 1)   # Red
set -g __omp_color_reset    (tput sgr0)

function __omp_escape -d "Escape string for CLI"
    string replace -ra "[\"'`]" "\\$&" -- $argv
end

function __omp_detect_shell -d "Detect current shell"
    echo "fish"
end

function __omp_log -d "Log with level"
    set -l level $argv[1]
    set -l msg $argv[2..-1]
    echo "[omp:$level] $msg" >&2
end

function __omp_build_context -d "Build auto-context for :s commands"
    # Current directory
    set -l cwd $PWD
    # Shell type
    set -l shell "fish"
    
    echo "Current directory: $cwd\nShell: $shell"
end
```

### Phase 2: Core Execution

**Goal**: The `:` command and `:s` command work.

#### 2.1 `__omp_exec.fish`

```fish
```fish
function __omp_exec_session -d "Execute omp in session mode"
    set -l prompt $argv[1]
    omp --continue -p $prompt
end
```
    set -l prompt $argv[1]

    # Build auto-context
    set -l context (__omp_build_context)

    # Combine prompt with context
    set -l full_prompt "$prompt

Context:
$context"

    # Stateless mode doesn't use model selection (--no-session)
    omp --no-session -p $full_prompt
end
```

#### 2.2 `__omp_dispatch.fish`

```fish
function __omp_dispatch -d "Parse and dispatch :commands"
    set -l input (string trim $argv)

    # Check if : is followed by space (prompt) or immediately by chars (subcommand)
    if string match -rq '^: \s' -- $input
        # `: <prompt>` - it's a prompt, strip leading `: ` and pass to omp
        set -l prompt (string replace -r '^: \s+' '' -- $input)
        __omp_exec_session $prompt
    else if string match -rq '^:\w' -- $input
        # `:command` - it's a subcommand
        set -l cmd (string replace -r '^:(\w+).*' '$1' -- $input)

        switch $cmd
            case 's'
                set -l prompt (string replace -r '^:s\s+' '' -- $input)
                __omp_exec_stateless $prompt

            case 'new'
                __omp_exec_session "Please clear the conversation context and be ready for a fresh start."

            case 'commit'
                set -l args (string replace -r '^:commit\s*' '' -- $input)
                if test -n "$args"
                    omp commit $args
                else
                    omp commit
                end

            case 'stats'
                omp stats

            case 'help'
                echo "omp-fish commands:"
                echo "  : <prompt>        - Continue or start session"
                echo "  :s <prompt>       - Stateless shell command (auto-context)"
                echo "  :new              - Reset session context"
                echo "  :commit           - AI commit"
                echo "  :commit --dry-run - Preview commit"
                echo "  :stats            - Show usage stats"

            case '*'
                echo "Unknown command: :$cmd"
                echo "Try :help for available commands"
                return 1
        end
    else
        # Just `:`, treat as empty prompt
        __omp_exec_session ""
    end
end
```

### Phase 3: Enter Key Integration

#### 3.1 `__omp_accept_line.fish`
```fish
function __omp_enable -d "Enable : command interception"
    bind \r '__omp_handle_enter'
end

function __omp_handle_enter -d "Handle Enter key for : commands"
    # commandline captures the entire input including multiline
    if commandline --search-match ":.*"
        set -l line (commandline)
        commandline -f clear
        __omp_dispatch $line
    else
        commandline -f execute
    end
end
```
### Phase 4: Auto-enable

#### 4.1 `conf.d/omp.fish`

```fish
# omp-fish auto-loader
if type -q omp
    # Enable : command interception
    __omp_enable
end
```

### Phase 5: TAB Completion

#### 5.1 `completions/omp.fish`

```fish
# Note: These completions are for the fish commandline, not omp itself
complete -c omp -f -a ":" -d "Start omp conversation"
complete -c omp -f -a ":s" -d "Stateless shell command"
complete -c omp -f -a ":new" -d "Reset session context"
complete -c omp -f -a ":commit" -d "AI commit"
complete -c omp -f -a ":stats" -d "Usage statistics"
complete -c omp -f -a ":help" -d "Show help"
```
## Open Questions for Discussion

### 1. `:s` Auto-context (Confirmed)

Auto-context includes (minimal):
- Current directory (`$PWD`)
- Shell type (`fish`)

No git info - keep it lightweight.

### 2. TTY/Prompt Integration

For now, we skip prompt integration to keep scope manageable. The right-prompt with stats is not feasible since `omp stats --json` returns historical totals, not session-specific usage.

This can be revisited later if needed.

### 3. Enter Key Approach

#### Why Key Binding is Needed

Fish parses commands before executing them. When you type `:hello` (no space), fish tries to find a command called `:hello`. Only `: hello` (with space) is parsed as `:` followed by arguments.

Intercept Enter key before fish parses the line:

```fish
# In conf.d/omp.fish
function __omp_enable
    bind \r __omp_handle_enter
end

function __omp_handle_enter
    set -l buffer (commandline)
    
    if string match -rq '^:' -- "$buffer"
        # It's a : command - intercept and dispatch
        history add -- "$buffer"
        commandline -f clear
        __omp_dispatch "$buffer"
    else
        # Normal command - execute normally
        commandline -f execute
    end
end
```

This handles ALL cases:
- `:` alone → dispatch (empty prompt)
- `:hello` → dispatch (subcommand like `:new`, `:s`)
- `: hello` → dispatch (prompt)
- `:s echo hello` → dispatch (stateless command)

**Key Binding is confirmed needed** - no alternative without it.

### 4. Error Handling

| Scenario | Behavior |
|----------|----------|
| omp non-zero exit | Echo error message, return 1 |
| Network/API error | Show error from omp output |
| Session not found | `--continue` auto-creates, no action needed |
| Invalid `:command` | Echo "Unknown command: :X" + help hint |
| Empty prompt after `:` | Show help or echo usage |

### 5. `:s` vs Plain `:` Detection (Confirmed)

- **`:s`** = stateless (`--no-session`), auto-context injected
- **:`** = session mode (`--continue`), prompt only

No auto-detection. Explicit `s` required. This keeps behavior predictable.
---

## Verification Checklist

- [ ] `:` opens omp with `--continue` (new session if none exists)
- [ ] Multiline input captured and passed correctly
- [ ] `:s echo hello` with auto-context (cwd + shell)
- [ ] `:new` resets session context
- [ ] `:commit` runs `omp commit`
- [ ] `:stats` opens stats dashboard
- [ ] TAB completion works for all commands
-- [ ] `:stats` opens stats dashboard
-- [ ] Key binding intercepts `:` commands

---

## Dependencies

- `omp` CLI installed (`which omp` should work)
- Fish shell (tested with fish 3.x+)
- `which fzf` should work (fzf 0.72.0 available)

---

## References

- Forge Code helpers: `~/.config/fish/functions/__forge_*.fish`
- omp CLI: https://github.com/can1357/oh-my-pi
- Verified with: omp v14.7.4
