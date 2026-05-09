# omp-zsh

A zsh plugin for [oh-my-pi](https://github.com/can1357/oh-my-pi) (`omp`). Turns `:`-prefixed commands into omp prompts directly from your zsh prompt.

## Requirements

- [zsh](https://www.zsh.org/) 5.8+
- [omp](https://github.com/can1357/oh-my-pi) CLI (`omp` on `$PATH`)

## Install

```zsh
# Copy plugin files into your zsh config
mkdir -p ~/.config/zsh/plugins/omp
git clone https://github.com/beeemT/omp-zsh.git ~/.config/zsh/plugins/omp

# Add to your .zshrc
source ~/.config/zsh/plugins/omp/omp.plugin.zsh
```

Or using a plugin manager:

**zinit:**
```zsh
zinit load beeemT/omp-zsh
```

**antidote:**
```zsh
# In plugins.txt
beeemT/omp-zsh
```

**zgen:**
```zsh
zgen load beeemT/omp-zsh
```

## Usage

| Command | Description |
|---------|-------------|
| `: <prompt>` | Start or continue an omp session |
| `:c <prompt>` | Continue session with last command context |
| `:s <prompt>` | Generate a shell command — output is placed in the buffer |
| `:new` | Reset session context, start fresh on next prompt |
| `:commit` | AI-assisted git commit |
| `:commit --dry-run` | Preview commit without committing |
| `:stats` | Show omp usage statistics |
| `:help` | List available commands |

### Examples

```zsh
# Start a conversation
: explain the authentication middleware

# Continue the same session
: and how would I add rate limiting?

# Get a shell command — output lands in your buffer, just press Enter
:s find all .ts files modified in the last week

# Continue with last command context (prepends last command + exit code)
:c why did this work

# Start fresh
:new

# AI commit
:commit

# Preview commit message
:commit --dry-run
```

### Multiline Prompts

Type multiline prompts using Shift+Enter. All lines are sent as a single prompt:

```
: This is line 1
This is line 2
This is line 3
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OMP_BIN` | `omp` | Path to OMP CLI binary |
| `OMP_TERM` | `true` | Enable terminal context capture for `:c` |

```zsh
# Custom omp binary location
export OMP_BIN="/path/to/custom/omp"

# Disable terminal context capture
export OMP_TERM="false"
```

## How it works

The plugin intercepts `:`-prefixed commands via a ZLE widget and routes them to the OMP CLI:

- `: <prompt>` → `omp "<prompt>"` (new session) or `omp -c "<prompt>"` (continue)
- `:c <prompt>` → `omp -c "<context>\n<prompt>"` (with last command context)
- `:s <prompt>` → `omp --no-session -p "<prompt>"` (stateless, output to buffer)
- `:new` → clears session state (no OMP call)
- `:commit` → `omp commit`
- `:stats` → `omp stats`

## File Structure

```
omp-zsh/
├── omp.plugin.zsh           # Main plugin entry point
├── lib/
│   ├── config.zsh           # Configuration variables
│   ├── dispatcher.zsh       # Main ZLE widget and command routing
│   ├── helpers.zsh          # Utility functions
│   ├── context.zsh          # Terminal context capture
│   ├── bindings.zsh         # Key bindings
│   ├── completion.zsh       # Completion widget
│   └── actions/
│       ├── core.zsh         # :new, :help, default : handling
│       ├── session.zsh      # :c (continue with context)
│       ├── suggest.zsh       # :s (command suggestion)
│       ├── commit.zsh        # :commit, :commit --dry-run
│       └── stats.zsh         # :stats
├── completions/
│   └── _omp                 # Zsh completion function
└── README.md
```

## License

[MIT](LICENSE)
