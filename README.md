# omp-fish

A fish shell plugin for [oh-my-pi](https://github.com/can1357/oh-my-pi) (`omp`). Turns `:`-prefixed commands into omp prompts directly from the fish prompt — no bind hacks, no repaint fights. Just native fish functions.

## Requirements

- [fish](https://fishshell.com/) 3.6+
- [omp](https://github.com/can1357/oh-my-pi) CLI (`omp` on `$PATH`)

## Install

```fish
# Copy plugin files into your fish config
mkdir -p ~/.config/fish/{conf.d,functions,completions}
cp conf.d/omp.fish ~/.config/fish/conf.d/
cp functions/*.fish ~/.config/fish/functions/
cp completions/omp.fish ~/.config/fish/completions/
```

Open a new fish session and you're ready.

## Usage

| Command | Description |
|---------|-------------|
| `: <prompt>` | Start or continue an omp session |
| `:s <prompt>` | Generate a shell command — output is placed in the buffer, press Enter to run |
| `:new` | Reset session context, start fresh on next prompt |
| `:commit` | AI-assisted git commit |
| `:commit --dry-run` | Preview commit without committing |
| `:stats` | Show omp usage statistics |
| `:help` | List available commands |

### Examples

```fish
# Start a conversation
: explain the authentication middleware

# Continue the same session
: and how would I add rate limiting?

# Get a shell command — output lands in your buffer, just press Enter
:s find all .ts files modified in the last week

# Start fresh
:new

# AI commit
:commit
```

## How it works

Each `:` command is a native fish function. Fish handles execution, output display, history, and prompt cycling the same way it does for any other command. No key bindings, no `commandline` hacks, no repaint timing issues.

`:s` captures omp's output and sets it as the commandline buffer content — review the generated command, edit if needed, and press Enter to run it.

## File structure

```
conf.d/omp.fish                   # Defines :, :s, :new, :commit, :stats, :help
functions/
  __omp_exec_session.fish         # Session mode (--continue / new session)
  __omp_exec_stateless.fish       # Stateless mode (--no-session), captures output
  __omp_build_context.fish        # Auto-context builder (cwd, shell)
  __omp_dispatch.fish             # Command parser (used by some internals)
  __omp_helpers.fish              # Shared utilities
completions/omp.fish              # TAB completions
```

## License

[MIT](LICENSE)
